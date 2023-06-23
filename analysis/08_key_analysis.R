# requirements
library(tidyverse)
library(ggbeeswarm)
library(ppcor)
library(lmerTest)

# data
dependency.df <- read_rds('tidy_data/tidy_dependency.rds')

# long --> wide
dependency.df %>%
  unite(col = 'ses_condition', session, condition, sep = '_') %>%
  pivot_wider(names_from = ses_condition, values_from = dependency, id_cols = subject_id) -> dependency.df

ppcor::pcor.test(x = dependency.df$`session1_famous person`, 
                 y = dependency.df$`session2_famous person`, 
                 z = dependency.df[,c('session1_famous place', 'session2_famous place')]) -> result1

ppcor::pcor.test(x = dependency.df$`session1_famous place`, 
                 y = dependency.df$`session2_famous place`, 
                 z = dependency.df[,c('session1_famous person', 'session2_famous person')]) -> result2

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