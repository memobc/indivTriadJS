# tidy the triads data

# requirements
library(tidyverse)

# load data
data.files <- list.files(pattern = '.*experiment_data.csv')
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'raw.csv')

# person, place stimuli lists
stim1 <- read_csv('../day1_experiment_data.csv')
stim2 <- read_csv('../day2_experiment_data.csv')
stim <- bind_rows(stim1, stim2)


## retrieval

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>% 
  select(-stimulus, -trial_type, -internal_node_id, -time_elapsed, -phase) -> joinedRetData.df

# encoding ----------------------------------------------------------------

numSubjects <- length(unique(interaction(df$subject, df$day)))

df %>%
  filter(phase == 'enc') -> onlyEncData.df

# catch trials
onlyEncData.df %>%
  filter(trial_type == 'survey-text') %>%
  select(where(~!all(is.na(.x))), -trial_type, -internal_node_id) -> catch_trials

write_csv(x = catch_trials, file = 'catch_trials.csv')

onlyEncData.df %>%
  filter(trial_type == 'html-keyboard-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus) %>%
  select(subject, trial_index , key, objOne, objTwo, day, encTrialNum) %>%
  mutate(keyType_enc = case_when(key %in% stim$people ~ 'famous person',
                             key %in% stim$place ~ 'everyday place',
                             TRUE ~ '')) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(subject, rt, response, day, encTrialNum) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df) %>%
  rename(success = response) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'tidy_enc.csv')

## Ret + Enc

left_join(joinedRetData.df, tidy.enc.df, by = c('subject', 'day', 'enc_trial_index' = 'trial_index'), 
          suffix = c('_ret', '_enc')) %>%
  arrange(subject, day, enc_trial_index) -> joinedData

findCorrectAnswer <- function(x){
  objOne <- x$objOne
  objTwo <- x$objTwo
  key <- x$key_enc
  resp_opts <- x %>% select(resp_opt_1:resp_opt_6) %>% as.list()
  correctResponse <- which(resp_opts %in% objOne | resp_opts %in% objTwo | resp_opts %in% key)
  if(length(correctResponse) > 1){
    correctResponse <- NA
  } else if(length(correctResponse) == 0){
    correctResponse <- NA
  }
  return(correctResponse)
}

# calculate isCorrect and correctResponse
joinedData %>%
  group_by(subject, day, trial_index) %>%
  nest() %>%
  mutate(correctResponse = map_int(.x = data, .f = findCorrectAnswer)) %>%
  unnest(data) %>%
  mutate(isCorrect = response == correctResponse) %>%
  mutate(keyType_ret = case_when(key_ret %in% stim$people ~ 'famous person',
                                key_ret %in% stim$place ~ 'everyday place',
                                TRUE ~ 'object')) -> tidy.df

write_csv(x = tidy.df, file = 'tidy_ret.csv')
