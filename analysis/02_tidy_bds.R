# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp <- read_rds('compiled_experiment.rds')

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
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, ~jsonlite::parse_json(.x) %>% as_tibble())) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, trial_index, time_elapsed, rt, bds_trialNum, Q0) %>%
  rename(response = Q0) -> bds.resp

df.exp %>%
  filter(phase == 'bds' & trial_type == 'html-keyboard-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(subject_id, study_id, session_id, trial_index, time_elapsed, bds_trialNum, stimulus) %>%
  mutate(stimulus = str_remove(stimulus, pattern = "<p style='font-size:48px'>"),
         stimulus = str_remove(stimulus, pattern = "</p>"),
         stimulus = as.double(stimulus)) %>%
  nest(bds_presentation = c(trial_index, time_elapsed, stimulus)) -> bds.pres

left_join(bds.pres, bds.resp) -> tidy.bds

saveRDS(tidy.bds, file = 'tidy_bds.rds')
