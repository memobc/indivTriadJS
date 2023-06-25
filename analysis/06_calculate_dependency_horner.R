# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)
library(magrittr)

# load data ---------------------------------------------------------------

graded.df <- read_rds('tidy_data/graded_df.rds')

# dependency --------------------------------------------------------------

# directory where you want to write out the temporary csv files
d <- 'work/'

# matlab command template
command_template <-"
/Applications/MATLAB_R2023a.app/bin/matlab -batch \"Calculate_Dependency('./{file}')\"
"

# tidy
graded.df %>% 
  pivot_longer(cols = ends_with('Correct'), names_to = 'type', values_to = 'isCorrect') %>% 
  dplyr::select(subject_id, session, condition, type, isCorrect, encTrialNum, ret_probe_pos) %>% 
  filter(!is.na(isCorrect)) %>%
  mutate(type = factor(type, levels = c('keyCorrect', 'objOneCorrect', 'objTwoCorrect'), labels = c('a', 'b', 'c'))) %>%
  mutate(ret_probe_pos = factor(ret_probe_pos, levels = c('key', 'objOne', 'objTwo'), labels = c('A', 'B', 'C'))) %>%
  unite(col = 'Pair', ret_probe_pos, type, sep = '') %>%
  pivot_wider(id_cols = all_of(c('subject_id', 'session', 'condition', 'encTrialNum')), names_from = Pair, values_from = isCorrect) %>%
  dplyr::select(-encTrialNum) %>%
  nest(cols = -all_of(c('subject_id', 'session', 'condition'))) %>%
  mutate(condition = str_remove(condition, ' ')) %>%
  mutate(file = str_glue('{d}sub-{subject_id}_sess-{session}_cond-{condition}.csv')) -> df

# write out
df %>%
  mutate(cols = walk2(.x = cols, .y = file, .f = write_csv, .progress = TRUE)) -> df

# matlab dependency with Horner Script. Takes a while to run...
df %>%
  mutate(command = str_glue(command_template)) %>%
  mutate(walk(command, system, .progress = TRUE)) -> df

# read in those files we just wrote out from MATLAB...

f <- list.files('work', 'dependency.*', full.names = T)
df <- map_dfr(f, \(file) read_csv(file, show_col_types = FALSE))

# tidy up
df %>%
  rowwise() %>%
  mutate(Data = mean(c_across(starts_with('Data')))) %>%
  mutate(Depend = mean(c_across(starts_with('Depend')))) %>%
  mutate(Indep = mean(c_across(starts_with('Indep')))) %>%
  ungroup() -> df

write_rds(df, 'tidy_data/tidy_horner.rds')
