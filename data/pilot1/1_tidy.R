# tidy the triads data

# requirements ------------------------------------------------------------

library(tidyverse)
library(assertthat)
source('toolbox/findCorrectAnswer.R')

# load data ---------------------------------------------------------------

data.files <- list.files(path = 'pilot1/', pattern = '.*experiment_data.csv', full.names = T)
df         <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'pilot1/1_raw_concatenated.csv')

people <- read_csv('../stim/famous_people.csv') %>%
        mutate(last = str_replace_na(last, '')) %>%
        transmute(name = str_c(first, last, sep = ' ')) %>%
        mutate(name = str_trim(name))
places <- read_csv('../stim/common_places.csv')

# retrieval ---------------------------------------------------------------
# select subset of data corresponding to retrieval

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -trial_type, -internal_node_id) -> onlyRetData.df

onlyRetData.df %>% filter(is.na(rt)) %>% select(where(~!all(is.na(.x))), -time_elapsed) -> choices.df
onlyRetData.df %>% filter(!is.na(rt)) %>% select(where(~!all(is.na(.x))), -time_elapsed) -> response.df

left_join(choices.df, response.df) %>%
  select(-phase) -> RetData.df

# encoding ----------------------------------------------------------------
# select subset of data that corresponds to encoding

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

write_csv(x = tidy.enc.df, file = 'pilot1/1_tidy_enc.csv')

# Knitting Enc + Ret together ---------------------------------------------
# The problem with pilot 1 was that I did not create a column that matches
# the encoding and retrieval trials to one another. Here we need to do that
# manually. Another bug was that, for some trials and for subjects, there 
# was accidentally doubles of some stimuli added to the experiment.

RetData.df %>% 
  add_column(trial_index_enc = NA) -> RetData.df

# for each row...
for(i in 1:nrow(RetData.df)){

  # the current row
  RetData.df %>% slice(i) -> rowN

  # this subject encoding data
  tidy.enc.df %>%
    filter(subject == rowN$subject) -> enc_thisS

  # try and match the retrieval key in this row to any of the encoding stimuli
  str_detect(enc_thisS$key, rowN$key) -> keyMatchVector 
  str_detect(enc_thisS$objOne, rowN$key) -> objOneMatchVector
  str_detect(enc_thisS$objTwo, rowN$key) -> objTwoMatchVector

  # BUG FIX -- some trials had multiple matches at encoding. Should not be the case.
  assert_that(sum(keyMatchVector) < 2, msg = 'More Than One Match')

  if(sum(objOneMatchVector < 2)){

    # see which of the two matches is in the response options
    rowN %>% 
      select(starts_with('resp_opt')) %>% 
      as_vector() -> resp_options

    enc_thisS %>% 
      filter(objOneMatchVector) -> TheMatches

    TheMatches %>% 
      filter(TheMatches$objTwo %in% resp_options) -> CorrectMatch

    # overwrite the match vector
    enc_thisS$trial_index %in% CorrectMatch$trial_index -> objOneMatchVector

  }

  assert_that(sum(objOneMatchVector) < 2, msg = 'More Than One Match')
  assert_that(sum(objTwoMatchVector) < 2, msg = 'More Than One Match')

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

write_csv(x = tidy.df, file = 'pilot1/1_tidy_ret.csv')
