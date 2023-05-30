# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp <- read_rds('compiled_experiment.rds')

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
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_debrief)) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, trial_index, time_elapsed, ends_with('Level')) -> tidy.debrief

saveRDS(tidy.debrief, file = 'tidy_debrief.rds')

#-- sam

extract_survey <- function(x, page_name){
  # x is a json formatted string
  jsonlite::parse_json(x) %>% 
    magrittr::extract2(page_name) %>%
    as_tibble()
}

df.exp %>%
  filter(phase == 'sam') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_survey, page_name = 'sam')) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, rt, matches('[0-9]$')) -> tidy.sam

saveRDS(tidy.sam, file = 'tidy_sam.rds')

#-- iri

df.exp %>%
  filter(phase == 'iri') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_survey, page_name = 'iri')) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, rt, matches('[0-9]$')) -> tidy.iri

saveRDS(tidy.iri, file = 'tidy_iri.rds')

#-- vviq

extract_vivq <- function(x){
  # x is a json formatted string.
  # the first entry is just text. It contains instructions.
  
  jsonlite::parse_json(x) %>% 
    magrittr::extract(-1) %>%
    as_tibble() %>%
    mutate(across(.fns = as.character)) %>%
    add_column(question_number = 1:4) %>%
    pivot_wider(values_from = vviq_relative:vviq_country, names_from = question_number)
}

df.exp %>%
  filter(phase == 'vviq') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, extract_vivq)) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, rt, matches('[0-9]$')) -> tidy.vviq

saveRDS(tidy.iri, file = 'tidy_vviq.rds')
