# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

tidy.interaction <- read_rds('compiled_interaction.rds')

# amount of blur and focus events as a table
tidy.interaction %>%
  unnest(data) %>%
  count(subject_id, event) %>%
  mutate(subject_id = factor(subject_id)) %>%
  filter(event %in% c('blur', 'focus')) %>%
  complete(subject_id, event, fill = list(n = 0)) -> tmp

tmp

# amount of blur and focus events as a graph
ggplot(data = tmp, aes(x = event, y = n)) +
  geom_point() +
  geom_line(aes(group = subject_id))
