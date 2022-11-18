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
                             TRUE ~ '')) %>%
  mutate(encTrialNum = rep(1:24, 10)) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(subject, rt, response, trial_index) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df) %>%
  rename(success = response) %>%
  nest(EncData = -subject) -> tidy.enc.df

## Ret + Enc

matchEncRet <- function(EncData, RetData){
    
  encTrialNum = array()
  for(i in 1:nrow(RetData)){
    key <- RetData[i,]$key
    index <- str_which(EncData$key, key)
    if(is_empty(index)){
      index <- str_which(EncData$objOne, key)
    }
    if(is_empty(index)){
      index <- str_which(EncData$objTwo, key)
    }
    encTrialNum[i] = index
  }
  
  RetData %>%
    add_column(encTrialNum) -> x
  
  return(x)

}

joinedRetData.df %>%
  nest(RetData = -subject) %>%
  left_join(tidy.enc.df) %>%
  mutate(MatchedData = map2(EncData, RetData, matchEncRet)) %>%
  select(subject, MatchedData) %>%
  unnest(cols = c(MatchedData)) -> joinedRetData.df

tidy.enc.df %>%
  unnest(EncData) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'tidy_enc.csv')

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
left_join(joinedRetData.df, tidy.enc.df, by = c('subject', 'encTrialNum'), suffix = c('_ret', '_enc')) %>%
  group_by(subject, trial_index_ret) %>%
  nest() %>%
  mutate(correctResponse = map_int(.x = data, .f = findCorrectAnswer)) %>%
  unnest(data) %>%
  mutate(isCorrect = response == correctResponse) %>%
  mutate(RetKeyType = case_when(key_ret %in% stim$people ~ 'famous person',
                                key_ret %in% stim$place ~ 'everyday place',
                                TRUE ~ 'object')) -> tidy.df

write_csv(x = tidy.df, file = 'tidy_ret.csv')
