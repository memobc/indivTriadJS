# prepare data for kernal ridge regression analysis
# prepare data for kernel ridge regression analysis with Kong et al. 2019's
# code

# requirements ------------------------------------------------------------

library(tidyverse)

# read data in ------------------------------------------------------------

graded.df  <- read_rds('analysis/tidy_data/graded_df.rds')
graded.bds <- read_rds('analysis/tidy_data/graded_bds.rds')
tidy.bias  <- read_rds(file = 'analysis/tidy_data/tidy_bias.rds')
tidy.sam   <- read_rds(file = 'analysis/tidy_data/tidy_sam.rds')
tidy.iri   <- read_rds(file = 'analysis/tidy_data/tidy_iri.rds')
tidy.vivq  <- read_rds(file = 'analysis/tidy_data/tidy_vviq.rds')

# raw data ----------------------------------------------------------------

graded.df %>%
  dplyr::select(subject_id, session, condition, trial_index, ends_with('Correct')) %>%
  pivot_longer(cols = ends_with('Correct'), names_to = 'thingCorrect', values_to = 'isCorrect') %>%
  group_by(subject_id) %>%
  mutate(overall_correct = mean(isCorrect, na.rm = TRUE)) %>%
  group_by(subject_id, condition, overall_correct) %>%
  summarise(across(isCorrect, ~mean(.x, na.rm = TRUE)), .groups = 'drop') %>%
  pivot_wider(names_from = condition, values_from = isCorrect) %>%
  mutate(person_bias = `famous person` - `famous place`) -> raw

# ground truth (y) --------------------------------------------------------

raw %>%
  dplyr::select(subject_id, overall_correct) %>%
  nest(y = -subject_id) -> y

raw %>%
  nest(raw = -subject_id) -> raw

# covariates --------------------------------------------------------------

graded.bds %>%
  #mutate(subject_id = factor(subject_id, labels = str_c('subject_', str_pad(1:60, pad = '0', side = 'left', width = 3)))) %>%
  dplyr::select(subject_id, isCorrect_prop) %>%
  nest(covariates = -subject_id) -> covariates

# subject ids -------------------------------------------------------------

# tmp %>%
#   #mutate(subject_id = factor(subject_id, labels = str_c('subject_', str_pad(1:60, pad = '0', side = 'left', width = 3)))) %>%
#   pull(subject_id) -> subject_ids

# features ----------------------------------------------------------------

tidy.vivq %>%
  rename(visual_imagery = response) -> tidy.vivq

left_join(tidy.bias, tidy.sam, by = 'subject_id') %>%
  left_join(tidy.iri, by = 'subject_id') %>%
  left_join(tidy.vivq, by = 'subject_id') %>%
  dplyr::select(-all_of(c('famous person', 'famous place', 'bias', 'rt.x', 'rt.y', 'rt'))) %>%
  nest(features = -subject_id) -> features

# line up -----------------------------------------------------------------
# make sure everything lines up

left_join(raw, y) %>%
  left_join(., covariates) %>%
  left_join(., features) -> joined.df

joined.df %>%
  dplyr::select(subject_id, raw) %>%
  unnest(raw) -> raw

joined.df %>%
  dplyr::select(subject_id, y) %>%
  unnest(y) -> y
  
joined.df %>%
  dplyr::select(subject_id, covariates) %>%
  unnest(covariates) -> covariates

joined.df %>%
  dplyr::select(subject_id, features) %>%
  unnest(features) -> features

joined.df %>%
  pull(subject_id) -> subject_ids

# write everything out ----------------------------------------------------

write_csv(x = raw, file = 'analysis/tidy_data/triads_data.csv')
write_csv(x = y, file = 'analysis/tidy_data/person_bias_ground_truth.csv')
write_csv(x = covariates, file = 'analysis/tidy_data/bds_performance.csv')
write_lines(subject_ids, file = 'analysis/tidy_data/subject_ids.txt')
write_csv(x = features, file = 'analysis/tidy_data/features.csv')
