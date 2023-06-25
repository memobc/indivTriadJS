# reanalyze bisby et al. 2018's data. Do they show a U-shaped relationship with overall performance?

# Requirements ------------------------------------------------------------

library(tidyverse)
library(readxl)
library(patchwork)

# Data from Exp1 ----------------------------------------------------------

# Data aren't in a nice tidyverse format. Manual reading in here
df <- read_excel('~/Downloads/NegContDisruptsCoh.xlsx', sheet = 'Experiment 1', range = 'N4:Y20', col_names = c('neu_Loc-Obj', 'neu_Pers-Loc', 'neu_Obj-Pers', 'neg_Loc-Obj', 'neg_Pers-Loc', 'neg_Obj-Pers',
                                                                                                                'neu_Data', 'neu_Independent', 'neu_Dependent', 'neg_Data', 'neg_Independent', 'neg_Dependent'))
df %>%
  add_column(subject = 1:17) -> df

# tidy
df %>%
  pivot_longer(cols = c(-subject), names_to = 'type', values_to = 'value') %>%
  separate(type, into = c('valence', 'type'), sep = '_') %>%
  pivot_wider(id_cols = all_of(c('subject', 'valence')), names_from = type, values_from = value) %>%
  rowwise() %>%
  mutate(Dependency = Data - Independent, 
         Performance = mean(c_across(all_of(c('Loc-Obj', 'Pers-Loc', 'Obj-Pers'))))) -> df

# investigate

ggplot(df, aes(x = Performance, y = Dependency)) +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x + I(x^2)) +
  geom_vline(xintercept = 0.17, color = 'red', linetype = 'dotted') +
  facet_grid(~valence) +
  labs(title = 'Experiment 1', subtitle = 'Concurrent Presentation', x = 'Associative Recognition Performance', caption = 'Red Line = Chance Performance (1/6 or ~0.17 or ~17%. Dots = subjects.') -> exp1

# Data from Exp 2 ---------------------------------------------------------

# Data aren't in a nice tidyverse format. Manual reading in here

data    <- c('Associative Recognition', 'Dependency')
order   <- c('Person Last', 'Person First')
valence <- c('neutral', 'negative')
type    <- c('Loc-Obj', 'Pers-Loc', 'Obj-Pers')

expand_grid(order, valence, type) %>%
  add_column(data = 'Associative Recognition') %>%
  mutate(column_name = str_glue('{data}_{order}_{valence}_{type}')) -> colNames.df.AssRecog

type <- c('Data', 'Indep', 'Depend')
expand_grid(order, valence, type) %>%
  add_column(data = 'Dependency') %>%
  mutate(column_name = str_glue('{data}_{order}_{valence}_{type}')) -> colNames.df.Depend

df <- read_excel('~/Downloads/NegContDisruptsCoh.xlsx', sheet = 'Experiment 2', range = 'A4:Y29', col_names = c('subject', colNames.df.AssRecog$column_name, colNames.df.Depend$column_name))

# tidy
df %>%
  pivot_longer(cols = c(-subject), names_to = 'type', values_to = 'value') %>%
  separate(type, into = c('data', 'condition', 'valence', 'type'), sep = '_') %>%
  pivot_wider(id_cols = all_of(c('subject', 'condition', 'valence')), names_from = type, values_from = value) %>%
  rowwise() %>%
  mutate(Dependency = Data - Indep, 
         Performance = mean(c_across(all_of(c('Loc-Obj', 'Pers-Loc', 'Obj-Pers'))))) -> df

# investigate

ggplot(df, aes(x = Performance, y = Dependency)) +
  geom_point() +
  geom_vline(xintercept = 0.17, color = 'red', linetype = 'dotted') +
  geom_smooth(method = 'lm', formula = y ~ x + I(x^2)) +
  facet_grid(condition~valence) +
  labs(title = 'Experiment 2', subtitle = 'Sequential Presentation', x = 'Associative Recognition Performance', caption = 'Red Line = Chance Performance (1/6 or ~0.17 or ~17%. Dots = subjects.') -> exp2

# experiment 3 ------------------------------------------------------------

# Data aren't in a nice tidyverse format. Manual reading in here

data    <- c('Associative Recognition', 'Dependency')
order   <- c('Person Last', 'Person First')
valence <- c('neutral', 'negative')
type    <- c('Loc-Obj', 'Pers-Loc', 'Obj-Pers')

expand_grid(order, valence, type) %>%
  add_column(data = 'Associative Recognition') %>%
  mutate(column_name = str_glue('{data}_{order}_{valence}_{type}')) -> colNames.df.AssRecog


type <- c('Data', 'Indep', 'Depend')
expand_grid(order, valence, type) %>%
  add_column(data = 'Dependency') %>%
  mutate(column_name = str_glue('{data}_{order}_{valence}_{type}')) -> colNames.df.Depend


df <- read_excel('~/Downloads/NegContDisruptsCoh.xlsx', sheet = 'Experiment 3', range = 'A4:Y30', col_names = c('subject', colNames.df.AssRecog$column_name, colNames.df.Depend$column_name))

# tidy
df %>%
  pivot_longer(cols = c(-subject), names_to = 'type', values_to = 'value') %>%
  separate(type, into = c('data', 'condition', 'valence', 'type'), sep = '_') %>%
  pivot_wider(id_cols = all_of(c('subject', 'condition', 'valence')), names_from = type, values_from = value) %>%
  rowwise() %>%
  mutate(Dependency = Data - Indep, 
         Performance = mean(c_across(all_of(c('Loc-Obj', 'Pers-Loc', 'Obj-Pers'))))) -> df

# investigate

ggplot(df, aes(x = Performance, y = Dependency)) +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x + I(x^2)) +
  geom_vline(xintercept = 0.17, color = 'red', linetype = 'dotted') +
  facet_grid(condition~valence) +
  labs(title = 'Experiment 3', 
       subtitle = 'Sequential Presentation 24 Hour Delay', 
       x = 'Associative Recognition Performance', 
       caption = 'Red Line = Chance Performance (1/6 or ~0.17 or ~17%. Dots = Subjects.') -> exp3

exp1 + exp2 + exp3 + plot_annotation(title = 'Bisby et al 2018')
