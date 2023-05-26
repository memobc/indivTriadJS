# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)
source('analysis/grade_cuedRecall.R')

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
  mutate(objOneCorrect = factor(objOneCorrect, levels = c(TRUE, FALSE)),
         objTwoCorrect = factor(objTwoCorrect, levels = c(TRUE, FALSE)),
         keyCorrect    = factor(keyCorrect, levels = c(TRUE, FALSE))) %>%
  select(subject_id, study_id, session_id, ret_probe, ret_probe_pos, ret_resp_1, ret_resp_2, condition:keyCorrect) -> graded.df

# dependency --------------------------------------------------------------

graded.df %>% 
  filter(ret_probe_pos == 'objOne') %>%
  nest(data = -all_of(c('subject_id','study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objTwoCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.AbAc

graded.df %>% 
  filter(ret_probe_pos == 'objTwo') %>%
  nest(data = -all_of(c('subject_id','study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.AbAc

graded.df %>% 
  filter(ret_probe_pos == 'key') %>%
  nest(data = -all_of(c('subject_id','study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + objTwoCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.AbAc

# In Ngo et al. 2021 language, the BaCa tables

graded.df %>%
  filter(ret_probe_pos != 'objOne') %>%
  pivot_wider(id_cols = c(subject_id, study_id, encTrialNum, condition), values_from = objOneCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.BaCa

graded.df %>%
  filter(ret_probe_pos != 'objTwo') %>%
  pivot_wider(id_cols = c(subject_id, study_id, encTrialNum, condition), values_from = objTwoCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objOne))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.BaCa

graded.df %>%
  filter(keyPosition != 'key') %>%
  pivot_wider(id_cols = c(subject_id, study_id, encTrialNum, condition), values_from = keyCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOne + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.BaCa

bind_rows(objOne.AbAc, objTwo.AbAc, key.AbAc, objOne.BaCa, objTwo.BaCa, key.BaCa, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.AbAc', 'objTwo.AbAc', 'key.AbAc', 'objOne.BaCa', 'objTwo.BaCa', 'key.BaCa'))) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> dependancy.df

# Independent Model

graded.df %>% 
  filter(keyPosition == 'objOne') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.Independent

graded.df %>% 
  filter(keyPosition == 'objTwo') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.Independent

graded.df %>% 
  filter(keyPosition == 'key') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.Independent

bind_rows(objOne.Independent, objTwo.Independent, key.Independent, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.Independent', 'objTwo.Independent', 'key.Independent'))) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> independent.df

left_join(dependancy.df, independent.df, by = c('subject', 'day', 'keyType_enc'), suffix = c('.data', '.indep')) -> final.dependancy
