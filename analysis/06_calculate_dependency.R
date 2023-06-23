# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

graded.df <- read_rds('tidy_data/graded_df.rds')
source('functions/independentModel.R')

# dependency --------------------------------------------------------------

graded.df %>% 
  filter(ret_probe_pos == 'objOne') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objTwoCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objOne.AbAc

graded.df %>% 
  filter(ret_probe_pos == 'objTwo') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objTwo.AbAc

graded.df %>% 
  filter(ret_probe_pos == 'key') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + objTwoCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> key.AbAc

# In Ngo et al. 2021 language, the BaCa tables

graded.df %>%
  filter(ret_probe_pos != 'objOne') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  pivot_wider(id_cols = c(subject_id, study_id, session, encTrialNum, condition), values_from = objOneCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objOne.BaCa

graded.df %>%
  filter(ret_probe_pos != 'objTwo') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  pivot_wider(id_cols = c(subject_id, study_id, session, encTrialNum, condition), values_from = objTwoCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objOne))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objTwo.BaCa

graded.df %>%
  filter(ret_probe_pos != 'key') %>%
  mutate(across(ends_with('Correct'), ~factor(.x, levels = c(TRUE, FALSE)))) %>%
  pivot_wider(id_cols = c(subject_id, study_id, session, encTrialNum, condition), values_from = keyCorrect, names_from = ret_probe_pos) %>%
  nest(data = -all_of(c('subject_id', 'study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOne + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> key.BaCa

bind_rows(objOne.AbAc, objTwo.AbAc, key.AbAc, objOne.BaCa, objTwo.BaCa, key.BaCa, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.AbAc', 'objTwo.AbAc', 'key.AbAc', 'objOne.BaCa', 'objTwo.BaCa', 'key.BaCa'))) %>%
  group_by(subject_id, study_id, session, condition) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> dependancy.df

# Independent Model

graded.df %>% 
  filter(ret_probe_pos == 'objOne') %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objOne.Independent

graded.df %>% 
  filter(ret_probe_pos == 'objTwo') %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> objTwo.Independent

graded.df %>% 
  filter(ret_probe_pos == 'key') %>%
  nest(data = -all_of(c('subject_id','study_id', 'session', 'condition'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  dplyr::select(-data, -TABS) -> key.Independent

bind_rows(objOne.Independent, objTwo.Independent, key.Independent, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.Independent', 'objTwo.Independent', 'key.Independent'))) %>%
  group_by(subject_id, study_id, session, condition) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> independent.df

left_join(dependancy.df, independent.df, 
          by = c('subject_id', 'study_id', 'session', 'condition'), 
          suffix = c('.data', '.indep')) -> final.dependancy

final.dependancy %>%
  mutate(dependency = joinedRetrieval.data - joinedRetrieval.indep) -> final.dependancy

write_rds(x = final.dependancy, file = 'tidy_data/tidy_dependency.rds')
