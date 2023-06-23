# tidy

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

df.exp   <- read_rds('tidy_data/compiled_experiment.rds')
tidy.enc <- read_rds('tidy_data/tidy_enc.rds')

# retrieval ---------------------------------------------------------------

df.exp %>%
  filter(phase == 'ret') %>%
  dplyr::select(where(~!all(is.na(.x)))) %>%
  mutate(response = map(response, ~jsonlite::parse_json(.x) %>% as_tibble())) %>%
  unnest(response) %>%
  dplyr::select(subject_id, study_id, session_id, session, trial_index, time_elapsed, rt, encTrialNum, key, Q0, Q1) %>%
  rename(ret_probe = key, ret_resp_1 = Q0, ret_resp_2 = Q1) %>%
  mutate(rt = as.double(rt)) -> tidy.ret

# only subjects with data from session 1 AND session 2
tidy.ret %>% 
  nest(data = -all_of(c('subject_id', 'session'))) %>% 
  pivot_wider(id_cols = subject_id, names_from = session, values_from = data) %>%
  filter(map_lgl(session1, is_tibble) & map_lgl(session2, is_tibble)) %>%
  pivot_longer(cols = starts_with('session'), names_to = 'session', values_to = 'data') %>%
  unnest(cols = c(data)) -> tidy.ret

left_join(tidy.ret, tidy.enc, by = c("subject_id", "study_id", "session", "session_id", "encTrialNum")) -> tidy.ret

saveRDS(tidy.ret, file = 'tidy_data/tidy_ret.rds')