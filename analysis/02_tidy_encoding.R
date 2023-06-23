# tidy the encoding data

# requirements ------------------------------------------------------------

library(tidyverse)

# load compiled data ------------------------------------------------------

df.exp <- read_rds('compiled_experiment.rds')

# tidy --------------------------------------------------------------------
# 
# Rows in df.exp represent events
# 
# Identify encoding presentation events, encoding imagination success events,
# and encoding catch trial events.
# 
# Only select relevant columns. Rename some columns for clarity.
#
# Write out data into separate encoding and catch trials tidy dataframes.
# Rows in these dataframes now represent trials

df.exp %>%
  filter(phase == 'enc') %>%
  filter(trial_type == 'html-keyboard-response') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  dplyr::select(subject_id, study_id, session_id, session, encTrialNum, trial_index, time_elapsed, objOne, objTwo, key, condition) %>%
  rename(trial_index_enc_pres = trial_index,
         time_elapsed_enc_pres = time_elapsed) -> enc.presention

df.exp %>%
  filter(phase == 'enc') %>%
  filter(trial_type == 'html-slider-response') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  dplyr::select(subject_id, study_id, session_id, session, encTrialNum, trial_index, rt, response, time_elapsed) %>%
  rename(trial_index_enc_slider = trial_index,
         time_elapsed_enc_slider = time_elapsed,
         rt_slider = rt,
         response_slider = response) %>%
  mutate(rt_slider = as.double(rt_slider)) %>%
  mutate(response_slider = as.double(response_slider)) -> enc.slider

df.exp %>%
  filter(phase == 'enc') %>%
  filter(trial_type == 'survey-text') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  dplyr::select(subject_id, study_id, session_id, session, encTrialNum, trial_index, time_elapsed, rt, response) %>%
  mutate(response = map_chr(response, ~jsonlite::parse_json(.x) %>% as.character)) %>%
  rename(trial_index_catch = trial_index,
         time_elapsed_catch = time_elapsed,
         rt_catch = rt) -> enc.catch

left_join(enc.presention, enc.slider, by = c('subject_id', 'study_id', 'session_id', 'session', 'encTrialNum')) -> tidy.enc

# only participants who have session1 and session2 data
tidy.enc %>% 
  nest(data = -all_of(c('subject_id', 'session'))) %>% 
  pivot_wider(id_cols = subject_id, names_from = session, values_from = data) %>% 
  filter(map_lgl(session1, is_tibble) & map_lgl(session2, is_tibble)) %>%
  pivot_longer(-subject_id, names_to = 'session', values_to = 'data') %>%
  unnest(cols = data) -> tidy.enc

saveRDS(tidy.enc, file = 'tidy_enc.rds')

left_join(enc.catch, enc.presention, by = c('subject_id', 'study_id', 'session_id', 'session', 'encTrialNum')) -> tidy.catch

saveRDS(tidy.catch, file = 'tidy_catch.rds')