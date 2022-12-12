# tidy the triads data

# requirements
library(tidyverse)
source('findCorrectAnswer.R')

# load data
data.files <- list.files(pattern = '.*experiment_data.csv')
df <- map_dfr(.x = data.files, .f = read_csv)
write_csv(x = df, file = 'raw.csv')

# person, place stimuli lists from day 1 and day 2
stim <- read_csv('../day1_experiment_data.csv')
stim <- bind_rows(stim, read_csv('../day2_experiment_data.csv'), .id = 'day')


# encoding ----------------------------------------------------------------

# subset only encoding data
df %>%
  filter(phase == 'enc') -> onlyEncData.df

onlyEncData.df %>%
  filter(trial_type == "html-keyboard-response") %>%
  # remove all unused columns
  select(where(~!all(is.na(.x)))) %>%
  select(where(~!all(.x == "null"))) %>%
  mutate(keyType_enc = case_when(key %in% stim$people ~ 'famous person',
                             key %in% stim$place ~ 'famous place',
                             TRUE ~ '')) %>%
  select(-stimulus, -internal_node_id, -trial_type) -> usefulEnc.df

df %>%
  filter(trial_type == 'html-slider-response') %>%
  select(where(~!all(is.na(.x)))) %>%
  select(-stimulus, -internal_node_id, -trial_index, -trial_type) -> tidy.enc.df

left_join(usefulEnc.df, tidy.enc.df, by = c('subject', 'day', 'encTrialNum', 'phase'), suffix = c('_triadPresentation', '_sliderStart')) %>%
  rename(success = response) %>%
  select(-phase) -> tidy.enc.df

write_csv(x = tidy.enc.df, file = 'tidy_enc.csv')

# retrieval ---------------------------------------------------------------

df %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, jsonlite::fromJSON)) %>%
  mutate(response = map(response, ~ as_tibble(.x))) %>%
  unnest(response) -> df.ret

df.ret %>%
  mutate(numAnswered = (str_length(Q0) > 0) + (str_length(Q1) > 0)) -> df.ret

# -- Distribution of Performance

df.ret %>%
  group_by(subject, day) %>%
  summarise(across(numAnswered, sum), totalPossible = n() * 2, .groups = 'drop') %>%
  mutate(propAnswered = numAnswered / totalPossible) -> propAnswered.SubjDay.df

ggplot(propAnswered.SubjDay.df, aes(x = propAnswered)) +
  geom_dotplot() +
  scale_x_continuous(breaks = seq(0, 1, .2)) +
  expand_limits(x = c(0,1)) +
  labs(title = 'Propotion of Cued Recall Responses Given', x = 'Proportion of Responses Answered')

# -- Distribution of Performance by Key Type

df.ret %>%
  left_join(., tidy.enc.df, by = c('subject', 'day', 'enc_trial_index' = 'trial_index'), suffix = c('_ret', '_enc')) %>%
  mutate(keyType_ret = case_when(key_ret %in% stim$people ~ 'famous person',
                             key_ret %in% stim$place ~ 'famous place',
                             TRUE ~ 'object')) %>%
  unite(col = 'keyType', keyType_ret, keyType_enc) %>%
  group_by(subject, day, keyType) %>%
  summarise(across(numAnswered, sum), totalPossible = n() * 2, .groups = 'drop') %>%
  mutate(propAnswered = numAnswered / totalPossible) -> propAnswered.df

ggplot(propAnswered.df, aes(y = propAnswered, x = keyType, color = factor(subject))) +
  stat_summary(aes(color = NULL), geom = 'crossbar', width = 0.2) +
  geom_point() +
  geom_line(aes(group = subject), linetype = 'dotted', alpha = 0.8) +
  facet_grid(~day, labeller = label_both) +
  theme(axis.text.x = element_text(angle = 90))

# -- How long did it take them to complete?

df %>%
  group_by(subject, day) %>%
  summarise(time_elapsed_ms = max(time_elapsed), .groups = 'drop') %>%
  mutate(time_elapsed_s = time_elapsed_ms/1000,
         time_elapsed_min = time_elapsed_s/60) -> timeElapsed.df

timeElapsed.df %>%
  ggplot(aes(x = day, y = time_elapsed_min)) +
  geom_point() +
  geom_line(aes(group = subject), linetype = 'dashed') +
  stat_summary(geom = 'crossbar', fun.data = mean_se, width = 0.2) +
  scale_y_continuous(breaks = c(seq(10,40,10), 175, 185)) +
  expand_limits(y = c(10,50)) +
  labs(title = 'How Long Participants Took To Complete the Experiment', y = 'Time Elapsed (min)', x = 'Day')

# -- Is performance predicted by imagination Success?

df.ret %>%
  left_join(., tidy.enc.df, by = c('subject', 'day', 'enc_trial_index' = 'trial_index'), suffix = c('_ret', '_enc')) %>%
  lme4::lmer(data = ., numAnswered ~ success + (1|subject)) -> model.fit

predict(model.fit.1, type = 'response') -> df.filtered$predictedProbCorrect
predict(model.fit.1, type = 'response', re.form = NA) -> df.filtered$predictedProbCorrectFixed

df.ret %>%
  left_join(., tidy.enc.df, by = c('subject', 'day', 'enc_trial_index' = 'trial_index'), suffix = c('_ret', '_enc')) %>%
  ggplot(., aes(x = success, y = )) +
  geom_point(shape = '|', position = position_jitter(width = 0.25, height = 0)) +
  geom_line(aes(group = subject, y = predictedProbCorrect, color = subject), alpha = 0.5) +
  geom_line(aes(y = predictedProbCorrectFixed), color = 'black', size = 2) +
  geom_hline(yintercept = 1/6, color = 'red', linetype = 'dotted') +
  labs(title = 'Success Ratings At Encoding Predict Retrieval Success',
       y = 'Retrieval Success (Probability)',
       x = 'Self-Reported Imaination Success at Encoding',
       caption = '')
