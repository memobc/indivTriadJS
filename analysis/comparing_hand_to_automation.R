# How does hand grading and automated grading compare?

tidy_graded <- read_rds('tidy_data/graded_df.rds')
tidy_hand   <- read_rds('tidy_data/tidy_handGraded.rds')

tidy_graded %>%
  rename(objOneCorrect_auto = objOneCorrect,
         objTwoCorrect_auto = objTwoCorrect,
         keyCorrect_auto = keyCorrect) -> tidy_graded

tidy_hand %>%
  rename(objOneCorrect_hand = objOneCorrect,
         objTwoCorrect_hand = objTwoCorrect,
         keyCorrect_hand = keyCorrect) -> tidy_hand

left_join(tidy_graded, tidy_hand) %>%
  dplyr::select(subject_id, session, trial_index, ret_probe:encTrialNum, ret_resp_1_isCorrect:objTwoCorrect_hand) %>%
  pivot_longer(c(ends_with('auto'), ends_with('hand')), names_sep = '_', names_to = c('position', 'gradeType'), values_to = 'isCorrect') %>%
  pivot_wider(names_from = gradeType, values_from = isCorrect) %>%
  filter(!is.na(auto) & !is.na(hand))
