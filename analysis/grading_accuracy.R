# How accurate was my grading algorithm?

library(tidyverse)
df <- read_csv('/Volumes/memolab/Data/Behavioral_Online/TRIADS/TRIADs/retrieval_tidy_edited.csv', show_col_types = F)

# correct the column name
df %>%
  mutate(ret_resp_2_isCorrect = case_when(ret_resp_2_isCorrect == 9 ~ '0',
                                          TRUE ~ ret_resp_2_isCorrect)) %>%
  mutate(ret_resp_1_isCorrect = as.numeric(ret_resp_1_isCorrect),
         ret_resp_2_isCorrect = as.numeric(ret_resp_2_isCorrect)) -> df

# unknowns ----------------------------------------------------------------

df %>%
  filter(is.na(ret_resp_1_isCorrect) | is.na(ret_resp_2_isCorrect)) -> unknowns

# both correct ------------------------------------------------------------

bothCorrect_fix <- function(x){

  ret_probe_idx <- which(c(x$objOne, x$objTwo, x$key) %in% x$ret_probe)

  if(ret_probe_idx == 1){
    tibble(objTwoCorrect = 1, keyCorrect = 1)
  } else if(ret_probe_idx == 2){
    tibble(objOneCorrect = 1, keyCorrect = 1)
  } else if(ret_probe_idx == 3){
    tibble(objOneCorrect = 1, objTwoCorrect = 1)
  }

}

df %>%
  filter(ret_resp_1_isCorrect == 1 & ret_resp_2_isCorrect == 1) %>%
  nest(cols = all_of(c('ret_probe', 'objOne', 'objTwo', 'key'))) %>% 
  mutate(gradesFixed = map(cols, bothCorrect_fix)) %>%
  unnest(cols = c(cols, gradesFixed)) -> bothCorrect

# both incorrect ----------------------------------------------------------

bothinCorrect_fix <- function(x){

  ret_probe_idx <- which(c(x$objOne, x$objTwo, x$key) %in% x$ret_probe)

  if(ret_probe_idx == 1){
    tibble(objTwoCorrect = 0, keyCorrect = 0)
  } else if(ret_probe_idx == 2){
    tibble(objOneCorrect = 0, keyCorrect = 0)
  } else if(ret_probe_idx == 3){
    tibble(objOneCorrect = 0, objTwoCorrect = 0)
  }

}

df %>%
  filter(ret_resp_1_isCorrect == 0 & ret_resp_2_isCorrect == 0) %>%
  nest(cols = all_of(c('ret_probe', 'objOne', 'objTwo', 'key'))) %>% 
  mutate(gradesFixed = map(cols, bothinCorrect_fix)) %>%
  unnest(cols = c(cols, gradesFixed)) -> bothIncorrect

# either or ---------------------------------------------------------------

eitherOr_fix <- function(x){

  ret_probe_idx   <- which(c(x$objOne, x$objTwo, x$key) %in% x$ret_probe)

  ret_resp        <- if_else(x$ret_resp_1_isCorrect == '1', x$ret_resp_1, x$ret_resp_2)
  if(ret_probe_idx == 1){
    objTwoCorrect <- agrepl(x = ret_resp, pattern = x$objTwo, ignore.case = TRUE, max.distance = 0.2)
    keyCorrect    <- agrepl(x = ret_resp, pattern = x$key, ignore.case = TRUE, max.distance = 0.55)
    tibble(objTwoCorrect, keyCorrect)
  } else if(ret_probe_idx == 2){
    objOneCorrect <- agrepl(x = ret_resp, pattern = x$objOne, ignore.case = TRUE, max.distance = 0.2)
    keyCorrect    <- agrepl(x = ret_resp, pattern = x$key, ignore.case = TRUE, max.distance = 0.55)
    tibble(objOneCorrect, keyCorrect)
  } else if(ret_probe_idx == 3){
    objOneCorrect <- agrepl(x = ret_resp, pattern = x$objOne, ignore.case = TRUE, max.distance = 0.2)
    objTwoCorrect <- agrepl(x = ret_resp, pattern = x$objTwo, ignore.case = TRUE, max.distance = 0.2)
    tibble(objOneCorrect, objTwoCorrect)
  }

}

df %>%
  filter(!is.na(ret_resp_1_isCorrect) & !is.na(ret_resp_2_isCorrect)) %>%
  filter(ret_resp_1_isCorrect != ret_resp_2_isCorrect) %>%
  nest(cols = all_of(c('ret_probe', 'objOne', 'objTwo', 'key', 'ret_resp_1', 'ret_resp_2', 'ret_resp_1_isCorrect', 'ret_resp_2_isCorrect'))) %>%
  mutate(gradesFixed = map(cols, eitherOr_fix)) %>%
  unnest(cols = c(cols, gradesFixed)) -> eitherOr

write_csv(file = '~/Downloads/eitherOr.csv', x = eitherOr)

# Hand Correct ------------------------------------------------------------
# Kyle goes through an makes a couple of hand corrections.

eitherOr <- read_csv('~/Downloads/eitherOr_handCorrected.csv', show_col_types = F)

eitherOr %>% 
  filter(!is.na(objOneCorrect) & !is.na(keyCorrect)) %>% 
  count(objOneCorrect, keyCorrect)

eitherOr %>% 
  filter(!is.na(objTwoCorrect) & !is.na(keyCorrect)) %>% 
  count(objTwoCorrect, keyCorrect)

eitherOr %>% 
  filter(!is.na(objTwoCorrect) & !is.na(objOneCorrect)) %>% 
  count(objTwoCorrect, objOneCorrect)

# Stitch Back Together ----------------------------------------------------

bind_rows(eitherOr, bothCorrect, bothIncorrect, unknowns) -> df

write_rds(x = df, file = 'tidy_data/tidy_handGraded.rds')
