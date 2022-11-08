# tidy the triads data

# requirements
library(tidyverse)

# load data
data.files <- list.files(pattern = '.*experiment_data.csv')
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'raw.csv')

# person, place stimuli lists
stim <- read_csv('../experiment_data.csv')

## retrieval

df %>%
  filter(phase == 'ret') -> onlyRetData.df

onlyRetData.df %>%
  filter(!is.na(stimulus)) %>%
  select(where(~!all(is.na(.x)))) %>% 
  select(rt, response, trial_index, subject) -> responseData.df

onlyRetData.df %>%
  filter(is.na(stimulus)) %>%
  select(where(~!all(is.na(.x)))) %>% 
  select(trial_index, subject, key:resp_opt_6) -> optionsData.df

left_join(responseData.df, optionsData.df) -> joinedRetData.df

# encoding ----------------------------------------------------------------

df %>%
  filter(phase == 'enc') -> onlyEncData.df

onlyEncData.df %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus) %>%
  select(subject, trial_index, key, objOne, objTwo) %>%
  mutate(trial_index = trial_index + 1) %>%
  mutate(keyType = case_when(key %in% stim$people ~ 'famous person',
                             key %in% stim$place ~ 'everyday place',
                             TRUE ~ '')) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(subject, rt, response, trial_index) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df) %>%
  rename(success = response) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'tidy_enc.csv')

## Ret + Enc

findCorrectAnswer <- function(x){
  objOne <- x$objOne
  objTwo <- x$objTwo
  resp_opts <- x %>% select(resp_opt_1:resp_opt_6) %>% as.list()
  correctResponse <- which(resp_opts %in% objOne | resp_opts %in% objTwo)
  if(length(correctResponse) > 1){
    correctResponse <- NA
  }
  return(correctResponse)
}

# calculate isCorrect and correctResponse
left_join(joinedRetData.df, tidy.enc.df, by = c('subject', 'key'), suffix = c('_ret', '_enc')) %>%
  filter(!is.na(objOne)) %>%
  group_by(subject, trial_index_ret) %>%
  nest() %>%
  mutate(correctResponse = map_int(.x = data, .f = findCorrectAnswer)) %>%
  unnest(data) %>%
  mutate(isCorrect = response == correctResponse) -> tidy.df

write_csv(x = tidy.df, file = 'tidy_ret.csv')
