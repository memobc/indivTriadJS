# compile data
# compile all available data into a single data frame

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

d      <- rstudioapi::selectDirectory()

# the rosetta stone -- translates prolific study ids into English

rosetta <- read_csv('metadata/study_id_rosetta.csv', show_col_types = F)

# prolific demographic data

f.dem <- list.files(path = d, pattern = 'prolific_export.*.csv', full.names = T)
extracted.study.id <- str_extract(f.dem, '(?<=export_).*(?=.csv)')

df.dem <- map(f.dem, read_csv, show_col_types = F)

tibble(study_id = extracted.study.id, dem.data = df.dem) %>%
  left_join(rosetta, by = join_by('study_id')) -> rosetta

# experimental data

f.exp  <- list.files(path = d, pattern = '.*data-experiment.csv', full.names = T)
df.exp <- map_dfr(f.exp, read_csv, show_col_types = F)

# There is one dataset that has subject_id, study_id, session_id listed as "NA".
# Without this information the dataset is unidentifiable. Remove from further consideration.
df.exp %>% filter(!is.na(subject_id)) -> df.exp

# light tidying
df.exp %>%
  mutate(version = factor(study_id, levels = rosetta$study_id, labels = rosetta$version)) %>%
  mutate(session = factor(study_id, levels = rosetta$study_id, labels = rosetta$session)) %>%
  mutate(phase = case_when(phase == 'instr' & trial_index %in% c(5,3) ~ 'instr_pre_enc',
                           phase == 'instr' & trial_index %in% c(66,64) ~ 'instr_pre_bds',
                           phase == 'instr' & trial_index %in% c(127,125) ~ 'instr_pre_ret',
                           TRUE ~ as.character(phase))) %>%
  mutate(phase = factor(phase, levels = rev(c('welcome_screen', 'consent', 'demographics', 'stim_ratings', 'instr_pre_enc', 'enc', 'instr_pre_bds', 'bds', 'instr_pre_ret', 'ret', 'debrief', 'sam', 'iri', 'vviq')))) %>%
  mutate(rt = as.double(rt)) -> df.exp

# only grab the first 60 subjects who have data from session 1 and session 2
rosetta %>%
  unnest(cols = dem.data) -> rosetta
  
df.exp %>%
  nest(data = -all_of(c('subject_id', 'session'))) %>%
  left_join(., rosetta, by = join_by('subject_id' == `Participant id`,'session')) %>%
  pivot_wider(id_cols = subject_id, names_from = 'session', values_from = c('Completed at', 'data')) %>%
  filter(map_lgl(data_session1, is_tibble) & map_lgl(data_session2, is_tibble)) %>%
  arrange(`Completed at_session2`) %>%
  slice(1:60) %>%
  dplyr::select(-starts_with('Completed at')) %>%
  pivot_longer(starts_with('data'), names_to = 'session', values_to = 'data') %>%
  mutate(session = str_remove(session, 'data_')) %>%
  unnest(cols = data) -> df.exp

write_rds(x = df.exp, file = 'tidy_data/compiled_experiment.rds')
