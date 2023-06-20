# requirements
library(tidyverse)
library(ggbeeswarm)
library(ppcor)
library(lmerTest)

# data
graded.df     <- read_rds('graded_df.rds')
dependency.df <- read_rds('tidy_dependency.rds')

# only subjects that have data from both sessions
dependency.df %>%
  group_by(subject_id) %>%
  mutate(N = n()) %>%
  filter(N == 4) -> dependency.df

# long --> wide
dependency.df %>%
  unite(col = 'ses_condition', study_id, condition, sep = '_') %>%
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

dependency.df %>%
  ungroup() %>%
  dplyr::select(-subject_id) %>%
  corrr::correlate() %>%
  corrr::autoplot()

dependency.df %>%
  mutate(fam_person = mean(`session1_famous person`, `session2_famous person`),
         fam_place  = mean(`session1_famous place`, `session2_famous place`)) %>%
  ggplot(aes(x = fam_person, y = fam_place)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0)

dependency.df %>%
  pivot_longer(names_to = 'sess_condition', values_to = 'dependency', cols = -subject_id) %>%
  separate(col = 'sess_condition', into = c('session', 'condition'), sep = '_') -> daData
  
lmer(data = daData, formula = dependency ~ condition + (1 + condition|subject_id)) -> model.fit

summary(model.fit)

ranova(model = model.fit, reduce.terms = F)

daData %>%
  pivot_wider(names_from = condition, values_from = dependency) %>%
  ggplot(aes(x = `famous person`, y = `famous place`, color = subject_id)) +
  geom_point() +
  geom_line(aes(group = subject_id)) +
  guides(color = 'none') +
  geom_abline(slope = 1, intercept = 0)
