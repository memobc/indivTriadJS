# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

tidy.enc <- read_rds('tidy_enc.rds')
tidy.ret <- read_rds('tidy_ret.rds')
tidy.bds <- read_rds('tidy_bds.rds')
tidy.catch <- read_rds('tidy_catch.rds')

# criterion 1 -------------------------------------------------------------
# participants who are statistical outliers (3 standard deviations below the mean)
# for reaction time for any 1 of our tasks

tidy.enc %>%
  group_by(subject_id, study_id) %>%
  summarise(rt_slider = mean(rt_slider)) %>%
  group_by(study_id) %>%
  mutate(zscore = as.double(scale(rt_slider))) %>%
  ungroup() %>%
  mutate(exclude_enc = zscore < -3)

tidy.ret %>%
  group_by(subject_id, study_id) %>%
  summarise(rt = mean(rt)) %>%
  group_by(study_id) %>%
  mutate(zscore = as.double(scale(rt))) %>%
  ungroup() %>%
  mutate(exclude_ret = zscore < -3)

tidy.bds %>%
  group_by(subject_id, study_id) %>%
  summarise(rt = mean(rt)) %>%
  group_by(study_id) %>%
  mutate(zscore = as.double(scale(rt))) %>%
  ungroup() %>%
  mutate(exclude_bds = zscore < -3)

# criterion 2 -------------------------------------------------------------
# participants who objectively demonstrated clear low-effort throughout 
# the experiment. Specifically participants are missing responses from more 
# than 90% of cued recall trials.

tidy.ret %>%
  pivot_longer(cols = starts_with('ret_resp'), names_to = 'resp_num', values_to = 'text_resp') %>%
  group_by(subject_id) %>%
  summarise(nblank = sum(text_resp == ""), total = n()) %>%
  mutate(prop = nblank / total) %>%
  mutate(exclude = prop > .9)

# criterion 3 -------------------------------------------------------------
# participants who objectively demonstrated clear low-effort throughout 
# the experiment. Specifically participants used the same response on the
# slider scale for every single encoding trial.

tidy.enc %>%
  group_by(subject_id, study_id) %>%
  summarise(sd_slider = sd(response_slider)) %>%
  mutate(exclude = sd_slider == 0)

# criterion 4 -------------------------------------------------------------
# participants who objectively demonstrated clear low-effort throughout 
# the experiment. Specifically participants responses to the catch trials 
# are nonsense

tidy.catch %>%
  select(subject_id, study_id, response)

# criterion 5 -------------------------------------------------------------
# participants who did not comprehend the instructions. Failed 2 of 3 
# instructions comprehension tests.