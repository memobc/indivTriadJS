# compare horner to my calculations

tidy.horner <- read_rds('tidy_data/tidy_horner.rds')
tidy.dependency <- read_rds('tidy_data/tidy_dependency.rds')

tidy.dependency %>%
  mutate(condition = str_remove(condition, ' ')) -> tidy.dependency

left_join(tidy.dependency, tidy.horner, 
          by = join_by('subject_id' == 'subj', 'session' == 'sess', 'condition' == 'cond')) -> joined.df

# Kyle's Calculations are Identical to Those from Aiden Horner's Script

