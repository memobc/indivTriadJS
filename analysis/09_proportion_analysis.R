# requirements
library(tidyverse)
library(ggbeeswarm)
library(ppcor)
library(lmerTest)

# data
graded.df     <- read_rds('tidy_data/graded_df.rds')

# long --> wide
graded.df %>%
  dplyr::select(subject_id, session, condition, trial_index, ends_with('Correct')) %>%
  pivot_longer(cols = ends_with('Correct'), names_to = 'thingCorrect', values_to = 'isCorrect') %>%
  group_by(subject_id, session, condition) %>%
  summarise(across(isCorrect, .fns = ~mean(.x, na.rm = TRUE)), .groups = 'drop') %>%
  unite(col = 'sess_cond', session, condition) %>%
  pivot_wider(id_cols = subject_id, names_from = sess_cond, values_from = isCorrect) -> graded.df

ppcor::pcor.test(x = graded.df$`session1_famous person`, 
                 y = graded.df$`session2_famous person`, 
                 z = graded.df[,c('session1_famous place', 'session2_famous place')]) -> result1

ppcor::pcor.test(x = graded.df$`session1_famous place`, 
                 y = graded.df$`session2_famous place`, 
                 z = graded.df[,c('session1_famous person', 'session2_famous person')]) -> result2

# decision

theMaxPvalue <- max(result1$p.value, result2$p.value)

if(theMaxPvalue < 0.035){
  print('Reject the Null Hypothesis')
}

if(theMaxPvalue > 0.282){
  print('Fail to Reject the Null Hypothesis')
}

if(theMaxPvalue > 0.035 & theMaxPvalue < 0.282){
  print('Inconclusive. Continue data collection.')
}
