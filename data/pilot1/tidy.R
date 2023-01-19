# tidy the triads data

# requirements
library(tidyverse)
source('findCorrectAnswer.R')

# load data
data.files <- list.files(path = 'pilot1', pattern = '.*experiment_data.csv', full.names = T)
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'pilot1/raw_concatenated.csv')

# retrieval ---------------------------------------------------------------

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -trial_type, -internal_node_id) -> onlyRetData.df

onlyRetData.df %>% filter(is.na(rt)) %>% select(where(~!all(is.na(.x))), -time_elapsed) -> choices.df
onlyRetData.df %>% filter(!is.na(rt)) %>% select(where(~!all(is.na(.x))), -time_elapsed) -> response.df

left_join(choices.df, response.df) %>%
  select(-phase) -> RetData.df

# encoding ----------------------------------------------------------------

# subset only encoding data
df %>%
  filter(phase == 'enc') -> onlyEncData.df

onlyEncData.df %>%
  filter(trial_type == "html-keyboard-response") %>%
  select(where(~!all(is.na(.x)))) %>%
  select(where(~!all(.x == "null"))) %>%
  select(-stimulus, -internal_node_id, -trial_type) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -internal_node_id, -trial_type) %>%
  mutate(trial_index = trial_index - 1) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df, by = c('subject', 'trial_index'), suffix = c('_triadPresentation', '_sliderStart')) %>%
  rename(success = response) %>%
  select(-phase) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'pilot1/tidy_enc.csv')

# Knitting Enc + Ret together ---------------------------------------------

RetData.df %>% 
  add_column(trial_index_enc = NA) -> RetData.df

for(i in 1:nrow(RetData.df)){

  RetData.df %>% slice(i) -> rowN

  tidy.enc.df %>%
    filter(subject == rowN$subject) -> enc_thisS

  str_detect(enc_thisS$key, rowN$key) -> keyMatchVector 
  str_detect(enc_thisS$objOne, rowN$key) -> objOneMatchVector
  str_detect(enc_thisS$objTwo, rowN$key) -> objTwoMatchVector

  assertthat::assert_that(sum(keyMatchVector) < 2, msg = 'More Then One Match')
  if(sum(objOneMatchVector < 2)){
    # see which of the two matches is in the response options
    rowN %>% select(starts_with('resp_opt')) %>% as_vector() -> resp_options
    enc_thisS %>% filter(objOneMatchVector) -> TheMatches
    
    TheMatches %>% filter(TheMatches$objTwo %in% resp_options) -> CorrectMatch
    
    # overwrite the match vector
    enc_thisS$trial_index %in% CorrectMatch$trial_index -> objOneMatchVector
    
  }
  assertthat::assert_that(sum(objOneMatchVector) < 2, msg = 'More Then One Match')
  assertthat::assert_that(sum(objTwoMatchVector) < 2, msg = 'More Then One Match')
  
  if(any(keyMatchVector)){
    RetData.df$trial_index_enc[i] <- enc_thisS$trial_index[keyMatchVector]
  }

  if(any(objOneMatchVector)){
    RetData.df$trial_index_enc[i] <- enc_thisS$trial_index[objOneMatchVector]
  }
  
  if(any(objTwoMatchVector)){
    RetData.df$trial_index_enc[i] <- enc_thisS$trial_index[objTwoMatchVector]
  }
  
}

left_join(RetData.df, tidy.enc.df,
          by = c("subject", "trial_index_enc" = "trial_index"),
          suffix = c('_ret', '_enc')) -> joinedRetData.df

# calculate isCorrect and correctResponse
joinedRetData.df %>%
  filter(!is.na(rt_ret)) %>%
  group_by(subject, trial_index) %>%
  nest() %>%
  mutate(correctResponse = map_int(.x = data, .f = findCorrectAnswer)) %>%
  unnest(data) %>%
  mutate(isCorrect = response == correctResponse) %>%
  ungroup() %>%
  rename(trial_index_ret = trial_index) -> tidy.df

write_csv(x = tidy.df, file = 'pilot1/tidy_ret.csv')
