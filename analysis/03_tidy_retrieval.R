# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp   <- read_rds('compiled_experiment.rds')
tidy.enc <- read_rds('tidy_enc.rds')

# retrieval ---------------------------------------------------------------

df.exp %>%
  filter(phase == 'ret') %>%
  select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, ~jsonlite::parse_json(.x) %>% as_tibble())) %>%
  unnest(response) %>%
  select(subject_id, study_id, session_id, trial_index, time_elapsed, rt, encTrialNum, key, Q0, Q1) %>%
  rename(ret_probe = key, ret_resp_1 = Q0, ret_resp_2 = Q1) -> tidy.ret

left_join(tidy.ret, tidy.enc, by = c("subject_id", "study_id", "session_id", "encTrialNum")) -> tidy.ret

saveRDS(tidy.ret, file = 'tidy_ret.rds')