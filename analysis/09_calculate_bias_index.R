# requirements
library(tidyverse)
library(ggbeeswarm)
library(ppcor)
library(lmerTest)

# data
dependency.df <- read_rds('tidy_data/tidy_dependency.rds')

dependency.df %>%
  pivot_wider(id_cols = all_of(c('subject_id', 'session')), names_from = condition, values_from = dependency) %>%
  group_by(subject_id) %>%
  mutate(person_prefer = `famous person` > `famous place`,
         place_prefer = `famous person` < `famous place`) %>%
  mutate(type = case_when(sum(person_prefer) == 2 ~ 'strong person bias',
                          sum(place_prefer) == 2 ~ 'strong place bias',
                          TRUE ~ 'ambiguous')) -> figureData

dependency.df %>%
  group_by(subject_id, condition) %>%
  summarise(across(.cols = dependency, .fns = mean), .groups = 'drop') %>%
  pivot_wider(names_from = 'condition', values_from = 'dependency') -> summarised.df

(ggplot(figureData, aes(x = `famous person`, y = `famous place`)) +
    guides(color = 'none') +
    theme_minimal() +
    scale_x_continuous(limits = c(-0.025, .45)) +
    scale_y_continuous(limits = c(-0.025, .45)) +
    theme(aspect.ratio = 1) -> blank)

(blank + geom_abline(slope = 1, intercept = 0, linetype = 'solid') -> blank)

(blank + 
    annotate(geom = 'polygon', x = c(0,0,.45), y = c(0,.45,.45), alpha = 0.3, fill = scales::muted('red')) +
    annotate(geom = 'label', x = 0.1, y = 0.4, label = '"place" bias', color = scales::muted('red')) -> blank)

(blank +
    annotate(geom = 'polygon', x = c(0,.45,.45), y = c(0,0,.45), alpha = 0.3, fill = scales::muted('blue')) +
    annotate(geom = 'label', x = 0.4, y = 0.1, label = '"person" bias', color = scales::muted('blue')) -> blank)

blank + 
  geom_point(data = summarised.df, shape = 'asterisk', size = 2)

blank +
  geom_point(data = summarised.df, shape = 'asterisk', size = 2) +
  geom_point(aes()) + 
  geom_path(aes(group = subject_id), linetype = 'solid')

blank + 
  geom_point(data = summarised.df, shape = 'asterisk', size = 2) +
  geom_point(aes(color = type)) + 
  geom_path(aes(group = subject_id, color = type)) + 
  scale_color_manual(values = c('black', 'blue', 'red'))

figureData %>%
  ungroup() %>%
  count(subject_id, type) %>%
  count(type)

blank + 
  geom_point(data = summarised.df, shape = 'asterisk', size = 2)

summarised.df %>%
  mutate(bias = `famous place` - `famous person`) -> bias.df

write_rds(x = bias.df, file = 'tidy_data/tidy_bias.rds')
