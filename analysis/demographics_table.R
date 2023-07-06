# create demographics table

library(tidyverse)
library(flextable)
source('functions/load_demographic.R')

d <- rstudioapi::selectDirectory()

df <- load_demographic(d)

df.exp <- read_rds('tidy_data/compiled_experiment.rds')

df.exp %>%
  nest(cols = -all_of(c('subject_id', 'study_id', 'session'))) %>%
  left_join(df, by = join_by('subject_id' == `Participant id`, 'study_id')) %>%
  filter(session == 'session1') %>%
  mutate(Sex = replace(Sex, Sex == 'DATA_EXPIRED', NA),
         `Country of birth` = replace(`Country of birth`, `Country of birth` == 'DATA_EXPIRED', NA),
         `Student status` = replace(`Student status`, `Student status` == 'DATA_EXPIRED', NA),
         `Employment status` = replace(`Employment status`, `Employment status` == 'DATA_EXPIRED', NA)) -> df

df %>%
  crosstable(cols = `Fluent languages`:`Employment status`, showNA = 'ifany', label = FALSE) %>%
  crosstable::as_flextable(compact = TRUE, fontsizes = list(body = 11, subheaders = 11, header = 11)) %>%
  flextable::delete_part() %>%
  flextable::save_as_image(path = 'Table1.png', res = 600)
