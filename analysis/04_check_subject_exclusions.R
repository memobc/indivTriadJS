# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

tidy.enc <- read_rds('tidy_enc.rds')
tidy.ret <- read_rds('tidy_ret.rds')
tidy.bds <- read_rds('tidy_bds.rds')

# criterion 1 -------------------------------------------------------------
# participants who are statistical outliers (3 standard deviations below the mean)
# for reaction time for any 1 of our tasks

tidy.enc %>%
  group_by(subject_id, session_id) %>%
  summarise(rt_slider = mean(rt_slider)) %>%
  group_by(session_id) %>%
  mutate(zscore = as.double(scale(rt_slider))) %>%
  ungroup() %>%
  mutate(exclude_enc = zscore < -3)

tidy.ret %>%
  group_by(subject_id, session_id) %>%
  summarise(rt = mean(rt)) %>%
  group_by(session_id) %>%
  mutate(zscore = as.double(scale(rt))) %>%
  ungroup() %>%
  mutate(exclude_ret = zscore < -3)

tidy.bds %>%
  group_by(subject_id, session_id) %>%
  summarise(rt = mean(rt)) %>%
  group_by(session_id) %>%
  mutate(zscore = as.double(scale(rt))) %>%
  ungroup() %>%
  mutate(exclude_bds = zscore < -3)

# criterion 2 -------------------------------------------------------------
# participants who objectively demonstrated clear low-effort throughout 
# the experiment. We are operationalizing this as:
#
# 1. gibberish/unintelligible catch trials
# 2. > 90% retrieval trials left blank
# 3. 