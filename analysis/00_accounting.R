# Lets account for the data

# requirements ------------------------------------------------------------

library(tidyverse) # <3

# load data ---------------------------------------------------------------

# the rosetta stone data frame. Hand created by Kyle. Translates the prolific study ids
# into English
rosetta <- read_csv('study_id_rosetta.csv') %>%
           rename(notes = ...4)

head(rosetta)

# prolific demographic data

f.dem <- list.files(path = d, pattern = 'prolific_export.*.csv', full.names = T)
extracted.study.id <- str_extract(f.dem, '(?<=export_).*(?=.csv)')

df.dem <- map(f.dem, read_csv, show_col_types = F)

tibble(study_id = extracted.study.id, dem.data = df.dem) %>%
  left_join(rosetta) -> rosetta

# experimental data

# choose where on your computer you have the data

f.exp  <- list.files(path = d, pattern = '.*data-experiment.csv', full.names = T)

df.exp <- map_dfr(f.exp, read_csv, show_col_types = F)

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

df.exp %>%
  nest(exp.data = -all_of(c('subject_id', 'study_id'))) -> df.exp

rosetta %>%
  unnest(cols = dem.data) -> rosetta

left_join(rosetta, df.exp, by = join_by(`Participant id` == subject_id, study_id)) -> tmp

tmp %>%
  filter(!map_lgl(.x = exp.data, .f = is_tibble)) %>%
  pull(`Participant id`) -> kyle

tmp %>%
  filter(`Participant id` %in% kyle) %>% view()

tmp %>% count(version, `Participant id`, study_id) %>% filter(is.na(version))

df.exp %>%
  group_by(subject_id) %>%
  mutate(hasBothSessions = n() == 2) %>%
  ungroup() %>%
  filter(hasBothSessions) %>%
  select(-hasBothSessions) %>%
  count(version, study_id)

write_rds(x = df.exp, file = 'compiled_experiment.rds')

# interaction data

f.int  <- list.files(path = d, pattern = '.*data-interaction.csv', full.names = T)

tibble(file = f.int) %>%
  mutate(data = map(file, read_csv, show_col_types = F),
         subject_id = str_extract(f.int, '(?<=sub-).*(?=_ses)'),
         session_id = str_extract(f.int, '(?<=ses-).*(?=_data)')) %>%
  select(-file) -> df.int

write_rds(x = df.int, file = 'compiled_interaction.rds')
