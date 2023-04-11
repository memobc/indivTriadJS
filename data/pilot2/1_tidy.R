# tidy the triads data

# requirements
library(tidyverse)
source('toolbox/findCorrectAnswer.R')

# load data
data.files <- list.files(path = '/Volumes/memolab/Data/TRIADs/pilot2/', pattern = '.*experiment_data.csv', full.names = TRUE)
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'pilot2/raw_concatenated.csv')

# person, place stimuli lists from day 1 and day 2
stim <- read_csv('../day1_experiment_data.csv')
stim <- bind_rows(stim, read_csv('../day2_experiment_data.csv'), .id = 'day')

# retrieval ---------------------------------------------------------------

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -trial_type, -internal_node_id, -phase) -> onlyRetData.df

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
  rename(success = response,
         trial_num_enc = encTrialNum) %>%
  select(-phase) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'pilot2/tidy_enc.csv')

# Knitting Enc + Ret together ---------------------------------------------

left_join(onlyRetData.df, tidy.enc.df, 
          by = c("subject", "day", "enc_trial_index" = "trial_index"), 
          suffix = c('_ret', '_enc')) %>% 
  rename(trial_index_ret = trial_index,
         trial_index_enc = enc_trial_index) -> joinedRetData.df

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

write_csv(x = tidy.df, file = 'pilot2/tidy_ret.csv')
