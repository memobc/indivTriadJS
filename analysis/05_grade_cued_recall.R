# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)
source('grade_cuedRecall.R')

# load data ---------------------------------------------------------------

tidy.ret <- read_rds('tidy_ret.rds')

# grade cued recall -------------------------------------------------------

tidy.ret %>%
  mutate(ret_probe_pos = case_when(ret_probe == key ~ 'key',
                                   ret_probe == objOne ~ 'objOne',
                                   ret_probe == objTwo ~ 'objTwo')) %>% 
  nest(data = c(ret_resp_1, ret_resp_2, ret_probe, condition, objOne, objTwo, key)) %>%
  mutate(isCorrect = map(data, grade_cuedRecall)) %>%
  unnest(cols = c(data, isCorrect)) %>%
  dplyr::select(subject_id, study_id, session_id, session, ret_probe, ret_probe_pos, ret_resp_1, ret_resp_2, condition:keyCorrect, encTrialNum, trial_index) -> graded.df

# only participants who have session1 and session2 data
graded.df %>% 
  nest(data = -all_of(c('subject_id', 'session'))) %>% 
  pivot_wider(id_cols = subject_id, names_from = session, values_from = data) %>% 
  filter(map_lgl(session1, is_tibble) & map_lgl(session2, is_tibble)) %>%
  pivot_longer(-subject_id, names_to = 'session', values_to = 'data') %>%
  unnest(cols = data) -> graded.df

write_rds(x = graded.df, file = 'graded_df.rds')
