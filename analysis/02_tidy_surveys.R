# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp <- read_rds('tidy_data/compiled_experiment.rds')

# surveys -----------------------------------------------------------------
# Rows in df.exp represent events
# 
# Identify events corresponding to the surveys
#
# For the survey responses, convert the text data from JSON to an R 
# compatible format. This process differs from survey to survey.
#
# Only select relevant columns. Rename some columns for clarity.
#
# Combine the tidy presentation and response data into a single
# backwards digit span tidy dataframe.
#
# For debriefing, each row represents a session
# For sam, iri, vviq each row represents a subject

#-- debriefing

extract_debrief <- function(x){
  # x is a json formatted string.
  # remove the first entry. first entry
  # in the survey is a text only survey
  # giving participants instructions
  # no data was collected.
  
  jsonlite::parse_json(x) %>% 
    magrittr::extract(-1) %>% 
    as_tibble()
}

df.exp %>%
  filter(phase == 'debrief') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_debrief)) %>%
  unnest(response) %>%
  dplyr::select(subject_id, study_id, session_id, session, trial_index, time_elapsed, ends_with('Level')) -> tidy.debrief

saveRDS(tidy.debrief, file = 'tidy_data/tidy_debrief.rds')

#-- sam

extract_survey <- function(x, page_name){
  # x is a json formatted string
  jsonlite::parse_json(x) %>% 
    magrittr::extract2(page_name) %>%
    as_tibble()
}

df.exp %>%
  filter(phase == 'sam') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_survey, page_name = 'sam')) %>%
  unnest(response) %>%
  dplyr::select(subject_id, study_id, session_id, session, rt, matches('[0-9]$')) -> tidy.sam

reverse_code_cols <- c('episodic_1', 'episodic_2', 'semantic_2', 'semantic_5', 'spatial_3', 'spatial_4', 'future_6')

code <- function(x, type){
  # x is a vector of responses 0-4 from jsPsych
  if(type == 'regular'){
    case_when(x == '0' ~ 1,
              x == '1' ~ 2,
              x == '2' ~ 3,
              x == '3' ~ 4,
              x == '4' ~ 5)
  } else if(type == 'reverse'){
    case_when(x == '0' ~ 5,
              x == '1' ~ 4,
              x == '2' ~ 3,
              x == '3' ~ 2,
              x == '4' ~ 1)
  }
}

tidy.sam %>%
  # reverse code: see Palombo et al. 2013 Appendix
  mutate(across(.cols = all_of(reverse_code_cols), .fns = ~code(.x, type = 'reverse'))) %>%
  mutate(across(.cols = !all_of(reverse_code_cols) & matches('_[0-9]$'), .fns = ~code(.x, type = 'regular'))) %>%
  dplyr::select(subject_id, study_id, session_id, session, rt, starts_with('episodic'), starts_with('semantic'), starts_with('spatial'), starts_with('future')) %>%
  pivot_longer(cols = matches('[0-9]$'), names_to = 'question', values_to = 'response') %>%
  separate(question, into = c('category', 'q')) %>%
  group_by(subject_id, rt, category) %>%
  summarise(across(response, .fns = ~sum(.x, na.rm = TRUE)), .groups = 'drop') -> tidy.sam

tidy.sam %>%
  pivot_wider(id_cols = all_of(c('subject_id', 'rt')), names_from = category, values_from = response) -> tidy.sam

saveRDS(tidy.sam, file = 'tidy_data/tidy_sam.rds')

#-- iri

iri_guide <- read_csv('metadata/IRI_guide.csv', show_col_types = FALSE)

score_iri <- function(x, reverse){
  if(reverse){
    return(
      case_when(x == '0' ~ 4,
                x == '1' ~ 3,
                x == '2' ~ 2,
                x == '3' ~ 1,
                x == '4' ~ 0)
    )
  } else {
    return(x)
  }
}

df.exp %>%
  filter(phase == 'iri') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_survey, page_name = 'iri')) %>%
  unnest(response) %>%
  dplyr::select(subject_id, study_id, session_id, session, rt, matches('[0-9]$')) %>%
  pivot_longer(cols = matches('[0-9]$'), names_to = 'question_number', values_to = 'response') %>%
  left_join(., iri_guide, by = c('question_number' = 'question')) %>%
  mutate(score = map2_dbl(.x = response, .y = reverse, .f = score_iri)) -> tidy.iri

tidy.iri %>%
  group_by(subject_id, rt, category) %>%
  summarise(across(score, .fns = ~sum(.x, na.rm = TRUE)), .groups = 'drop') -> tidy.iri

tidy.iri %>%
  pivot_wider(id_cols = all_of(c('subject_id', 'rt')), names_from = category, values_from = score) -> tidy.iri

saveRDS(tidy.iri, file = 'tidy_data/tidy_iri.rds')

#-- vviq

extract_vivq <- function(x){
  # x is a json formatted string.

  jsonlite::parse_json(x) -> parsedText

  parsedText %>%
    unlist() %>%
    as_tibble_row()
}

df.exp %>%
  filter(phase == 'vviq') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_vivq)) %>%
  unnest(cols = response) %>%
  dplyr::select(subject_id, study_id, session_id, session, rt, matches('[0-9]$')) %>%
  pivot_longer(cols = matches('[0-9]$'), names_to = 'question_number', values_to = 'response') %>%
  group_by(subject_id, rt) %>%
  summarise(across(response, ~sum(.x, na.rm = TRUE)), .groups = 'drop') -> tidy_vivq

saveRDS(tidy_vivq, file = 'tidy_data/tidy_vviq.rds')
