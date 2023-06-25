# implement a multilevel model using lavaan to estimate dependency

library(lavaan)

df <- read_rds('tidy_data/graded_df.rds')

df %>% 
  arrange(subject_id, session, encTrialNum) %>% 
  mutate(encTrial = rep(rep(1:24, each = 3), 62*2)) %>%
  arrange(subject_id, session, trial_index) %>%
  mutate(retTrial = rep(1:72, 124)) %>%
  pivot_longer(cols = ends_with('Correct'), names_to = 'target', values_to = 'isCorrect') %>%
  filter(!is.na(isCorrect)) %>%
  dplyr::select(subject_id, session, condition, encTrial, retTrial, ret_probe_pos, target, isCorrect) %>%
  # for mplus, force all factors to numeric codes
  mutate(subject_id = factor(subject_id, labels = 1:62)) %>%
  mutate(session = factor(session, levels = c('session1', 'session2'), labels = c(1,2))) %>%
  mutate(condition = factor(condition, levels = c('famous place', 'famous person'), labels = c(1,2))) %>%
  mutate(ret_probe_pos = factor(ret_probe_pos, levels = c('objOne', 'objTwo', 'key'), labels = c(1,2,3))) %>%
  mutate(target = factor(target, levels = c('objOneCorrect', 'objTwoCorrect', 'keyCorrect'), labels = c(1,2,3))) %>%
  mutate(isCorrect = as.numeric(isCorrect)) %>%
  write_delim(file = 'test.txt', col_names = FALSE) -> df
