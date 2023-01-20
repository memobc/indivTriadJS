# tidy the triads data

# requirements
library(tidyverse)
source('findCorrectAnswer.R')
source('independentModel.R')

# load data
data.files <- list.files(pattern = '.*experiment_data.csv', path = 'pilot4', full.names = TRUE)
df <- map_dfr(.x = data.files, .f = read_csv, col_type = cols(subject = col_factor()))
write_csv(x = df, file = 'pilot4/raw_concatenated.csv')

# person, place stimuli lists from day 1 and day 2
stim <- read_csv('../day1_experiment_data.csv')
stim <- bind_rows(stim, read_csv('../day2_experiment_data.csv'), .id = 'day')

# Familiarity Ratings -----------------------------------------------------

# people

df %>%
  filter(phase == 'people_ratings') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(ratings = map(response, ~jsonlite::fromJSON(.x) %>% as_tibble())) %>%
  unnest(ratings) %>%
  pivot_longer(`Robert Pattinson`:`Scarlett Johansson`, names_to = 'celeb', values_to = 'rating') %>%
  filter(!is.na(rating)) %>%
  select(subject, day, celeb, rating) -> peopleRatings

peopleRatings %>%
  mutate(celeb = factor(celeb), celeb = fct_reorder(.f = celeb, .x = rating, .fun = mean, .desc = T)) %>%
  ggplot(aes(x = celeb, y = rating)) +
  stat_summary(geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = 'Celeb Familarity Ratings', subtitle = 'Descending by Average Rating')

peopleRatings %>%
  mutate(celeb = factor(celeb), celeb = fct_reorder(.f = celeb, .x = rating, .fun = sd, .desc = T)) %>%
  ggplot(aes(x = celeb, y = rating)) +
  stat_summary(geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = 'Celeb Familarity Ratings', subtitle = 'Descending by Rating Variation')

# place

df %>%
  filter(phase == 'place_ratings') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(ratings = map(response, ~jsonlite::fromJSON(.x) %>% as_tibble())) %>%
  unnest(ratings) %>%
  pivot_longer(`The Bird's Nest, Beijing`:`Notre-Dame, Paris`, names_to = 'place', values_to = 'rating') %>%
  filter(!is.na(rating)) %>%
  select(subject, day, place, rating) -> placeRatings

placeRatings %>%
  mutate(place = factor(place), place = fct_reorder(.f = place, .x = rating, .fun = mean, .desc = T)) %>%
  ggplot(aes(x = place, y = rating)) +
  stat_summary(geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = 'Place Familarity Ratings', subtitle = 'Descending by Average Rating')

placeRatings %>%
  mutate(place = factor(place), place = fct_reorder(.f = place, .x = rating, .fun = sd, .desc = T)) %>%
  ggplot(aes(x = place, y = rating)) +
  stat_summary(geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = 'Place Familarity Ratings', subtitle = 'Descending by Rating Variation')


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
  select(-phase) %>%
  mutate(success = as.double(success)) -> tidy.enc.df

ggplot(tidy.enc.df, aes(x = keyType_enc, y = success)) +
  geom_point() +
  stat_summary(geom = 'crossbar', width = 0.2, fun.data = mean_se, fill = 'cyan') +
  labs(title = 'Encoding Success Ratings', subtitle = 'Famous Person Triads Were More Successfully Imagined', x = 'Triad Type') +
  facet_grid(~day, labeller = label_both)

lme4::lmer(data = tidy.enc.df, formula = success ~ 1 + (1|subject)) -> model.fit.0
lme4::lmer(data = tidy.enc.df, formula = success ~ keyType_enc + (1|subject)) -> model.fit.1
anova(model.fit.0, model.fit.1)

write_csv(x = tidy.enc.df, file = 'pilot4/tidy_enc.csv')

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
  #unite(col = 'keyType', keyType_ret, keyType_enc) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(numAnswered, sum), totalPossible = n() * 2, .groups = 'drop') %>%
  mutate(propAnswered = numAnswered / totalPossible) -> propAnswered.df

ggplot(propAnswered.df, aes(y = propAnswered, x = keyType_enc, color = factor(subject))) +
  stat_summary(aes(color = NULL), geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  geom_point() +
  geom_line(aes(group = subject), linetype = 'dotted', alpha = 0.8) +
  facet_grid(~day, labeller = label_both) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = 'Proportion Answered', subtitle = 'People Varied Significantly on the Proportion of Responses Provided',
       color = 'subject',
       y = 'Proportion of Cued Recall Responses Given Any Answer', x = 'Triad Type')

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
  lme4::lmer(data = ., numAnswered ~ success + (1|subject)) -> model.fit.1

df.ret %>%
  left_join(., tidy.enc.df, by = c('subject', 'day', 'enc_trial_index' = 'trial_index'), suffix = c('_ret', '_enc')) %>%
  mutate(keyType_ret = case_when(key_ret %in% stim$people ~ 'famous person',
                                 key_ret %in% stim$place ~ 'famous place',
                                 TRUE ~ 'object')) %>%
  unite(col = 'keyType', keyType_ret, keyType_enc) -> joined.df

predict(model.fit.1, type = 'response') -> joined.df$predictedProbCorrect
predict(model.fit.1, type = 'response', re.form = NA) -> joined.df$predictedProbCorrectFixed

joined.df %>%
  ggplot(., aes(x = success, y = numAnswered)) +
  geom_point(shape = '|', position = position_jitter(width = 0.25, height = 0)) +
  geom_line(aes(group = subject, y = predictedProbCorrect, color = subject), alpha = 0.5) +
  geom_line(aes(y = predictedProbCorrectFixed), color = 'black', size = 2) +
  geom_hline(yintercept = 1/6, color = 'red', linetype = 'dotted') +
  labs(title = 'Success Ratings At Encoding Predict Retrieval Success',
       y = 'Retrieval Success (Probability)',
       x = 'Self-Reported Imaination Success at Encoding',
       caption = '')

source('grade_cuedRecall.R')

joined.df %>%
  separate(col = keyType, into = c('keyType_ret', 'keyType_enc'), sep = '_') %>%
  nest(data = c(Q0, Q1, key_ret, objOne, objTwo, key_enc)) %>%
  mutate(isCorrect = map(data, grade_cuedRecall)) %>%
  unnest(cols = c(data, isCorrect)) %>%
  mutate(objOneCorrect = factor(objOneCorrect, levels = c(TRUE, FALSE)),
         objTwoCorrect = factor(objTwoCorrect, levels = c(TRUE, FALSE)),
         keyCorrect    = factor(keyCorrect, levels = c(TRUE, FALSE))) %>%
  mutate(keyPosition = case_when(is.na(objOneCorrect) ~ 'objOne',
                                 is.na(objTwoCorrect) ~ 'objTwo',
                                 is.na(keyCorrect) ~ 'key')) -> joined.df

# In Ngo et al. 2021 language, the AbAc tables

joined.df %>% 
  filter(keyPosition == 'objOne') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objTwoCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.AbAc

joined.df %>% 
  filter(keyPosition == 'objTwo') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + keyCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.AbAc

joined.df %>% 
  filter(keyPosition == 'key') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOneCorrect + objTwoCorrect))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.AbAc

# In Ngo et al. 2021 language, the BaCa tables

joined.df %>%
  filter(keyPosition != 'objOne') %>%
  pivot_wider(id_cols = c(subject, day, encTrialNum, keyType_enc), values_from = objOneCorrect, names_from = keyPosition) %>%
  nest(data = -all_of(c('subject', 'day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.BaCa

joined.df %>%
  filter(keyPosition != 'objTwo') %>%
  pivot_wider(id_cols = c(subject, day, encTrialNum, keyType_enc), values_from = objTwoCorrect, names_from = keyPosition) %>%
  nest(data = -all_of(c('subject', 'day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ key + objOne))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.BaCa

joined.df %>%
  filter(keyPosition != 'key') %>%
  pivot_wider(id_cols = c(subject, day, encTrialNum, keyType_enc), values_from = keyCorrect, names_from = keyPosition) %>%
  nest(data = -all_of(c('subject', 'day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, ~xtabs(data = .x, formula = ~ objOne + objTwo))) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.BaCa

bind_rows(objOne.AbAc, objTwo.AbAc, key.AbAc, objOne.BaCa, objTwo.BaCa, key.BaCa, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.AbAc', 'objTwo.AbAc', 'key.AbAc', 'objOne.BaCa', 'objTwo.BaCa', 'key.BaCa'))) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> dependancy.df

# Independent Model

joined.df %>% 
  filter(keyPosition == 'objOne') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objOne.Independent

joined.df %>% 
  filter(keyPosition == 'objTwo') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> objTwo.Independent

joined.df %>% 
  filter(keyPosition == 'key') %>%
  nest(data = -all_of(c('subject','day', 'keyType_enc'))) %>%
  mutate(TABS = map(data, independentModel)) %>%
  mutate(joinedRetrieval = map_dbl(TABS, ~ (.x[1,1] + .x[2,2]) / sum(.x))) %>%
  select(-data, -TABS) -> key.Independent

bind_rows(objOne.Independent, objTwo.Independent, key.Independent, .id = 'type') %>%
  mutate(type = factor(type, labels = c('objOne.Independent', 'objTwo.Independent', 'key.Independent'))) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(joinedRetrieval, mean), .groups = 'drop') -> independent.df

left_join(dependancy.df, independent.df, by = c('subject', 'day', 'keyType_enc'), suffix = c('.data', '.indep')) -> final.dependancy

final.dependancy %>%
  pivot_longer(cols = starts_with('joinedRetrieval'), names_to = 'modelType', values_to = 'propJoinedRetreival') %>%
  ggplot(aes(x = modelType, y = propJoinedRetreival, color = factor(subject))) +
  geom_point() +
  geom_line(aes(group = factor(subject)), linetype = 'dotted') +
  stat_summary(aes(color = NULL), geom = 'crossbar', width = 0.2, fun.data = mean_se) +
  facet_grid(keyType_enc~day, labeller = label_value) +
  scale_x_discrete(labels = c('data', 'independent')) +
  labs(title = 'Retrieval Dependancy', subtitle = 'By Day and Triad Type', color = 'subject', x = 'Model Type', y = 'Proportion of Joint Retrieval')

final.dependancy %>%
  mutate(diff = joinedRetrieval.data - joinedRetrieval.indep) %>%
  ggplot(aes(x = keyType_enc, y = diff, color = factor(subject))) +
  geom_point() +
  stat_summary(aes(color = NULL), geom = 'crossbar', fun.data = mean_se, width = 0.2) +
  geom_line(aes(group = factor(subject)), linetype = 'dotted') +
  facet_grid(~day, labeller = label_both) +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(y = 'Data - Independent', x = 'Triad Type', color = 'subject', title = 'Retrieval Dependancy', subtile = 'By Day and Triad Type')

## Performance

joined.df %>%
  mutate(across(objOneCorrect:keyCorrect, as.logical)) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(objOneCorrect:keyCorrect, sum, na.rm = TRUE), .groups = 'drop') %>%
  rowwise() %>%
  mutate(totalCorrect = sum(c_across(ends_with('Correct'))), propCorrect = totalCorrect / 72) -> overallPerformance.data

overallPerformance.data %>%
  ggplot(aes(x = keyType_enc, y = propCorrect, color = factor(subject))) +
  geom_point() +
  geom_line(aes(group = subject), linetype = 'dotted') +
  stat_summary(aes(color = NULL), geom = 'crossbar', width = 0.2, fun.data = 'mean_se') +
  facet_grid(~day, labeller = label_both) +
  theme(axis.text.x = element_text(angle = 90), aspect.ratio = 1) +
  scale_color_discrete(labels = str_pad(seq(1,14,1), width = 3, pad = '0')) +
  labs(title = 'Overall Performance on Cued Recall Pilot',
       subtitle = 'People did significantly better on famous person triads',
       color = 'subject',
       x = 'Triad Type',
       y = 'Prop Correct using `agrep`') -> plot1

ggsave(filename = '', plot = plot1)

library(lme4)

lmer(propCorrect ~ 1 + (1|subject), data = overallPerformance.data) -> model.fit.0
lmer(propCorrect ~ keyType_enc + (1|subject), data = overallPerformance.data) -> model.fit.1
lmer(propCorrect ~ keyType_enc + day + (1|subject), data = overallPerformance.data) -> model.fit.2
lmer(propCorrect ~ keyType_enc + (keyType_enc|subject), data = overallPerformance.data) -> model.fit.3
anova(model.fit.0, model.fit.1)

overallPerformance_Dependency.df %>%
  group_by(subject) %>%
  summarise(across(all_of(c('propCorrect', 'diff')), .fns = mean), .groups = 'drop') %>%
  ggplot(aes(x = propCorrect, y = diff)) +
  geom_point() +
  labs(x = 'Proportion of Correct Respones (Overall Performance)', 
       y = 'Data - Independent (Dependency)', 
       title = 'Relationship between Dependency and Performance', 
       caption = 'dots = subject')

overallPerformance_Dependency.df %>%
  group_by(subject) %>%
  summarise(across(all_of(c('propCorrect', 'diff')), .fns = mean), .groups = 'drop') %>%
  select(propCorrect, diff) %>%
  corrr::correlate()

df <- read_csv('/Users/kylea/Downloads/pspc_data_v1.csv')

df %>% 
  select(PC_Accuracy, Dependency) -> important.df

important.df %>%
  corrr::correlate()

ggplot(important.df, aes(x = PC_Accuracy, y = Dependency)) +
  geom_point() +
  labs(title = 'Relationship Between Dependency and Performance', subtitle = 'In the Ngo et al. 2021 dataset')

## The actual test of the hypothesis

final.dependancy %>%
  mutate(diff = joinedRetrieval.data - joinedRetrieval.indep) %>%
  select(-joinedRetrieval.data, -joinedRetrieval.indep) %>%
  pivot_wider(values_from = diff, names_from = c(day, keyType_enc)) %>%
  filter(across(.fns = ~!is.na(.x))) -> final.data

final.data %>%
  select(-subject) %>%
  corrr::correlate()

GGally::ggpairs(final.data %>% select(-subject))

# Do Ratings Predict Performance? ------------------------------------------

peopleRatings %>% rename(key_enc = celeb) -> peopleRatings
placeRatings %>% rename(key_enc = place) -> placeRatings

bind_rows(peopleRatings, placeRatings) %>%
  left_join(joined.df, ., by = c('subject', 'day', 'key_enc')) %>%
  mutate(across(objOneCorrect:keyCorrect, as.logical)) %>%
  rowwise() %>%
  mutate(numCorrect = sum(c_across(objOneCorrect:keyCorrect), na.rm = TRUE)) %>%
  group_by(subject, day, encTrialNum) %>%
  summarise(numCorrect = sum(numCorrect),
            rating = unique(rating),
            key_enc = unique(key_enc), .groups = 'drop') %>%
  mutate(keyType_enc = case_when(key_enc %in% stim$people ~ 'famous person',
                                 key_enc %in% stim$place ~ 'famous place',
                                 TRUE ~ '')) -> performanceCelebFam.df

ggplot(performanceCelebFam.df, aes(x = keyType_enc, y = rating)) +
  geom_dotplot(binaxis = 'y', method = 'histodot', stackdir = 'center', dotsize = 0.1, ) +
  stat_summary(geom = 'crossbar', fun.data = mean_se, width = 0.2, fill = 'cyan') +
  labs(title = 'Familiarity/Imageability Ratings', subtitle = 'Of the Top 12 Stimuli Selected for the Experiment', x = 'Triad Type') +
  facet_grid(~day, labeller = label_both)

lme4::lmer(data = performanceCelebFam.df, formula = rating ~ 1 + (1|subject)) -> model.fit.0
lme4::lmer(data = performanceCelebFam.df, formula = rating ~ keyType_enc + (1|subject)) -> model.fit.1
lme4::lmer(data = performanceCelebFam.df, formula = rating ~ day + (1|subject)) -> model.fit.2
anova(model.fit.0, model.fit.1)

# Does the Performance Difference Hold Up When Only Looking at the Famous Person/Place as the Cue?

joined.df %>%
  filter(keyType_ret != 'object') %>%
  mutate(across(objOneCorrect:keyCorrect, as.logical)) %>%
  rowwise() %>%
  mutate(numCorrect = sum(c_across(objOneCorrect:keyCorrect), na.rm = TRUE)) %>%
  group_by(subject, day, encTrialNum) %>%
  summarise(numCorrect = sum(numCorrect),
            key_enc = unique(key_enc), .groups = 'drop') %>%
  mutate(keyType_enc = case_when(key_enc %in% stim$people ~ 'famous person',
                                 key_enc %in% stim$place ~ 'famous place',
                                 TRUE ~ '')) %>%
  group_by(subject, day, keyType_enc) %>%
  summarise(across(numCorrect, sum), .groups = 'drop') %>%
  mutate(prop = numCorrect / 24) %>%
  ggplot(aes(x = keyType_enc, y = prop, color = factor(subject))) +
    geom_point() +
    geom_line(aes(group = factor(subject)), linetype = 'dashed') +
    stat_summary(aes(color = NULL, group = NULL), geom = 'crossbar', fun.data = mean_se, width = 0.2) +
  facet_grid(~day, labeller = label_both) +
  labs(title = 'Propotion Correct', subtitle = 'Only Looking at Retrieval Trials with the Famous Person/Place as the Memory Cue',
       x = 'Triad Type', y = 'Proportion Correct using `agrep`')

lme4::lmer()
