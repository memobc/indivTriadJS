# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp <- read_rds('tidy_data/compiled_experiment.rds')

# backwards digit span ----------------------------------------------------
# 
# Rows in df.exp represent events
# 
# Identify backwards digit span events corresponding to presentation and
# participants response.
#
# For the responses, convert the text data from JSON to an R compatible
# format.
#
# For the presentations, remove the html formatting leaving just the 
# number that was presented. Store the bds stimulus presentations as
# a nested data frame.
# 
# Only select relevant columns. Rename some columns for clarity.
#
# Combine the tidy presentation and response data into a single
# backwards digit span tidy dataframe. Each row represents a bds
# trial

df.exp %>%
  filter(phase == 'bds' & trial_type == 'survey-text') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, ~jsonlite::parse_json(.x) %>% as_tibble())) %>%
  unnest(response) %>%
  dplyr::select(subject_id, study_id, session_id, session, trial_index, time_elapsed, rt, bds_trialNum, Q0) %>%
  rename(response = Q0) %>%
  mutate(rt = as.double(rt)) -> bds.resp

df.exp %>%
  filter(phase == 'bds' & trial_type == 'html-keyboard-response') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  dplyr::select(subject_id, study_id, session_id, session, trial_index, time_elapsed, bds_trialNum, stimulus) %>%
  mutate(stimulus = str_remove(stimulus, pattern = "<p style='font-size:48px'>"),
         stimulus = str_remove(stimulus, pattern = "</p>"),
         stimulus = as.double(stimulus)) %>%
  nest(bds_presentation = c(trial_index, time_elapsed, stimulus)) -> bds.pres

left_join(bds.pres, bds.resp, by = join_by(subject_id, study_id, session_id, session, bds_trialNum)) -> tidy.bds

saveRDS(tidy.bds, file = 'tidy_data/tidy_bds.rds')
