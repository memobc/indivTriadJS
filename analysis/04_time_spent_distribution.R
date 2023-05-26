# How long did participants spend on each part of the experiment?

library(tidyverse)

df <- read_rds('compiled_experiment.rds')

# calculate how much time participants are spending in each part of the experiment

df %>%
  filter(phase %in% c('enc', 'bds', 'ret')) %>%
  arrange(subject_id, trial_index) %>%
  group_by(subject_id, phase) %>%
  slice(c(1,n())) %>%
  group_by(subject_id, phase) %>%
  summarise(time_spend = diff(time_elapsed), trial_index = max(trial_index)) -> timespent.task

df %>%
  filter(!phase %in% c('bds', 'enc', 'ret')) %>%
  arrange(subject_id, trial_index) %>%
  select(subject_id, trial_index, phase, rt) %>%
  filter(!is.na(rt)) %>%
  mutate(rt = as.double(rt)) %>%
  rename(time_spend = rt) -> timespent.all.else

timespent.all.else %>%
  mutate(phase = case_when(phase == 'instr' & trial_index == 5 ~ 'instr_pre_enc',
                           phase == 'instr' & trial_index == 66 ~ 'instr_pre_bds',
                           phase == 'instr' & trial_index == 127 ~ 'instr_pre_ret',
                           TRUE ~ as.character(phase))) %>%
  bind_rows(., timespent.task) %>%
  arrange(subject_id, trial_index) %>%
  mutate(subject_id = factor(subject_id, labels = c('s001', 's002', 's003', 's004', 's005'))) %>%
  mutate(phase = factor(phase, levels = rev(c('welcome_screen', 'consent', 'demographics', 'stim_ratings', 'instr_pre_enc', 'enc', 'instr_pre_bds', 'bds', 'instr_pre_ret', 'ret', 'debrief')))) %>%
  mutate(time_spend = time_spend / 1000 / 60) -> tidy.timespend

tidy.timespend %>% 
  group_by(phase) %>% 
  summarize(across(time_spend, sd)) %>% 
  arrange(time_spend)

# overview
ggplot(tidy.timespend, aes(x = subject_id, y = time_spend)) +
  geom_col(aes(fill = phase)) +
  geom_label(stat = 'summary', fun = sum, aes(label = round(after_stat(y), 1))) +
  scale_fill_brewer(type = 'qual', palette = 'Set3') +
  labs(y = 'time spent (min)', x = 'subject', title = 'Where did subject spend their time?')

# callouts

Set3 <- RColorBrewer::brewer.pal(11, 'Set3')

# subject 5 spent 6 minutes on the welcome screen
tidy.timespend %>%
  filter(phase == 'welcome_screen') %>%
  ggplot(aes(x = subject_id, y = time_spend, fill = phase)) +
  geom_col() +
  geom_label(aes(label = round(time_spend, 1), fill = NULL)) +
  scale_fill_manual(values = Set3[length(Set3)]) +
  labs(y = 'time spent (min)', x = 'subject', title = 'Subject 5 spent 6 minutes on the welcome screen') +
  scale_y_continuous(limits = c(0, 60))

# Subject 1 spend 16 minutes on the bds instructions
tidy.timespend %>%
  filter(phase == 'instr_pre_bds') %>%
  ggplot(aes(x = subject_id, y = time_spend, fill = phase)) +
  geom_col() +
  geom_label(aes(label = round(time_spend, 1), fill = NULL)) +
  scale_fill_manual(values = Set3[length(Set3)-6]) +
  labs(y = 'time spent (min)', x = 'subject', title = 'Subject 1 spent 17 minutes on the backwards digit span instructions...') +
  scale_y_continuous(limits = c(0, 60))

tidy.timespend %>%
  filter(phase == 'ret') %>%
  ggplot(aes(x = subject_id, y = time_spend, fill = phase)) +
  geom_col() +
  geom_label(aes(label = round(time_spend, 1), fill = NULL)) +
  scale_fill_manual(values = Set3[2]) +
  labs(y = 'time spent (min)', x = 'subject', title = 'Subject 5 spent 30 minutes on the cued recall alone') +
  scale_y_continuous(limits = c(0, 60))

tidy.timespend %>%
  filter(phase == 'enc') %>%
  ggplot(aes(x = subject_id, y = time_spend, fill = phase)) +
  geom_col() +
  geom_label(aes(label = round(time_spend, 1), fill = NULL)) +
  scale_fill_manual(values = Set3[2]) +
  labs(y = 'time spent (min)', x = 'subject', title = 'Subject 1 spent 16 minutes on the backwards digit span instructions') +
  scale_y_continuous(limits = c(0, 60))
