# tidy the triads data

# requirements
library(tidyverse)
source('findCorrectAnswer.R')

# load data
data.files <- list.files(pattern = '.*experiment_data.csv')
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'raw.csv')

# person, place stimuli lists from day 1 and day 2
stim <- read_csv('../day1_experiment_data.csv')
stim <- bind_rows(stim, read_csv('../day2_experiment_data.csv'), .id = 'day')

# retrieval ---------------------------------------------------------------

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -trial_type, -internal_node_id) -> onlyRetData.df

# encoding ----------------------------------------------------------------

# subset only encoding data
df %>%
  filter(phase == 'enc') -> onlyEncData.df

onlyEncData.df %>%
  filter(trial_type == "html-keyboard-response") %>%
  # remove all unused columns
  select(where(~!all(is.na(.x)))) %>%
  select(where(~!all(.x == "null"))) %>%
  mutate(keyType = case_when(key %in% stim$people ~ 'famous person',
                             key %in% stim$place ~ 'famous place',
                             TRUE ~ '')) %>%
  select(-stimulus, -internal_node_id, -trial_type) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -internal_node_id, -trial_index, -trial_type) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df, by = c('subject', 'day', 'encTrialNum', 'phase'), suffix = c('_triadPresentation', '_sliderStart')) %>%
  rename(success = response) %>%
  select(-phase) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'tidy_enc.csv')

# Knitting Enc + Ret together ---------------------------------------------

left_join(tidy.enc.df, onlyRetData.df, by = c("subject", "day", "trial_index" = "enc_trial_index"), suffix = c('_enc', '_ret')) %>% 
  select(-trial_index) -> joinedRetData.df

# calculate isCorrect and correctResponse
joinedRetData.df %>%
  filter(!is.na(rt_ret)) %>%
  group_by(subject, day, trial_index_ret) %>%
  nest() %>%
  mutate(correctResponse = map_int(.x = data, .f = findCorrectAnswer)) %>%
  unnest(data) %>%
  mutate(isCorrect = response == correctResponse) %>%
  mutate(RetKeyType = case_when(key_ret %in% stim$people ~ 'famous person',
                                key_ret %in% stim$place ~ 'famous place',
                                TRUE ~ 'object')) %>% 
  ungroup() -> tidy.df

write_csv(x = tidy.df, file = 'tidy_ret.csv')
