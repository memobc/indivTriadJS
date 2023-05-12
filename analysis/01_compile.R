# compile data
# compile all available data into a single data frame

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

d      <- choose.dir(caption = 'Select Data Folder')

# experimental data

f.exp  <- list.files(path = d, pattern = '.*data-experiment.csv', full.names = T)

df.exp <- map_dfr(f.exp, read_csv, show_col_types = F)

df.exp %>% pull(subject_id) %>% unique() -> prolific_subject_ids

# light tidying
df.exp %>%
  mutate(subject_id = factor(subject_id, levels = prolific_subject_ids, labels = str_c('s00', 1:length(prolific_subject_ids)))) %>%
  mutate(phase = case_when(phase == 'instr' & trial_index == 5 ~ 'instr_pre_enc',
                           phase == 'instr' & trial_index == 66 ~ 'instr_pre_bds',
                           phase == 'instr' & trial_index == 127 ~ 'instr_pre_ret',
                           TRUE ~ as.character(phase))) %>%
  mutate(phase = factor(phase, levels = rev(c('welcome_screen', 'consent', 'demographics', 'stim_ratings', 'instr_pre_enc', 'enc', 'instr_pre_bds', 'bds', 'instr_pre_ret', 'ret', 'debrief')))) %>%
  mutate(rt = as.double(rt)) -> df.exp

write_rds(x = df.exp, file = 'compiled_experiment.rds')

# interaction data

f.int  <- list.files(path = d, pattern = '.*data-interaction.csv', full.names = T)

tibble(file = f.int) %>%
  mutate(data = map(file, read_csv, show_col_types = F),
         subject_id = str_extract(f.int, '(?<=sub-).*(?=_ses)'),
         session_id = str_extract(f.int, '(?<=ses-).*(?=_data)')) %>%
  mutate(subject_id = factor(subject_id, levels = prolific_subject_ids, labels = str_c('s00', 1:length(prolific_subject_ids)))) %>%
  select(-file) -> df.int

write_rds(x = df.int, file = 'compiled_interaction.rds')
