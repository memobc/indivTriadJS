# generate experiment data csv

# requirements ------------------------------------------------------------
library(tidyverse)

# body
files <- list.files('Stimuli/Nina_similar_famous_faces_noBR', pattern = '.*.png')

organize <- function(listEntry){
  if(length(listEntry) == 2){
    listEntry %>%
      magrittr::set_names(x = ., value = c('first', 'last')) %>%
      enframe() %>%
      pivot_wider()
  } else {
    tibble(first = listEntry, last = NA)
  }
}

# remove the tail end of the file name; find unique entries; split into
# first and last names; make a data frame
files %>%
  str_remove(string = ., pattern = '_[12]__?br.png') %>%
  str_remove(string = ., pattern = '_br_[12].png') %>%
  unique() %>%
  str_split(string = ., pattern = '_') %>%
  map_dfr(., organize) -> celeb.names

celeb.names %>%
  mutate(first = str_to_sentence(first),
         last = str_to_sentence(last)) %>%
  distinct() -> celeb.names

# fix select names by hand
celeb.names %>%
  mutate(first = case_when(first == 'Johnf' ~ 'John F.',
                           first == 'Dalai' ~ 'The Dalai',
                           TRUE ~ first)) %>%
  mutate(last = case_when(last == 'Lutherking' ~ 'Luther King',
                          last == 'Mcconaughey' ~ 'McConaughey',
                          last == 'Mccarthy' ~ 'McCarthy',
                          last == 'Mccartney' ~ 'McCartney',
                          last == 'Mcadams' ~ 'McAdams',
                          last == 'Downeyjr' ~ 'Downey Jr.',
                          last == 'Ljackson' ~ 'L. Jackson',
                          TRUE ~ last)) -> celeb.names

# places ------------------------------------------------------------------

# body
place.names <- readxl::read_excel(path = 'Stimuli/famous_places.xlsx')

# objects -----------------------------------------------------------------

# body
df <- read_csv(file = 'Stimuli/BOSS_norms_maureen_condensed.csv')

# arrange by name agreement, only non-living objects
df %>%
  arrange(desc(NameAgreement)) %>%
  filter(Living == 'Non-Living') %>%
  head(n = 130) %>%
  select(ModalName) %>%
  distinct() %>%
  pull(ModalName) -> object.names

# fix select names by hand
object.names %>%
  str_to_lower() -> object.names

object.names %>%
  str_subset(., 'eiffel tower', negate = TRUE) %>%
  str_subset(., 'no parking sign', negate = TRUE) %>%
  str_subset(., 'condom', negate = TRUE) %>%
  str_subset(., 'tampon', negate = TRUE) -> object.names

# build -------------------------------------------------------------------
# build to experiment data

## celeb names

set.seed(123)

# select 24 people to be presented on day 1
celeb.names %>%
  sample_n(size = 26) -> day1

# remove those 24 people from the pool; select 24 more to be presented on day 2
celeb.names %>%
  anti_join(., day1) %>%
  sample_n(size = 26) -> day2

bind_rows(day1, day2, .id = 'day') -> select.celebs

select.celebs %>%
  mutate(last = str_replace_na(last, replacement = ''),
         people = str_c(first, last, sep = ' '),
         people = str_trim(people)) %>%
  select(-first, -last) %>%
  add_row(day = '1', people = NA, .after = 26) %>% 
  add_row(day = '1', people = NA, .after = 27) %>%
  add_row(day = '2', people = NA) %>% 
  add_row(day = '2', people = NA) -> select.celebs

## Place

set.seed(123)
place.names %>%
  as_tibble() %>%
  sample_n(size = 26) -> day1

place.names %>%
  as_tibble() %>%
  anti_join(., day1) %>%
  sample_n(size = 26) -> day2

bind_rows(day1, day2, .id = 'day') -> select.places

select.places %>%
  rename(place = `Unique Places`) %>%
  add_row(day = '1', place = NA, .after = 26) %>%
  add_row(day = '1', place = NA, .after = 27) %>%
  add_row(day = '2', place = NA) %>%
  add_row(day = '2', place = NA) -> select.places

## objects

set.seed(123)
object.names %>%
  as_tibble() %>%
  sample_n(size = 56) -> day1

object.names %>%
  as_tibble() %>%
  anti_join(., day1) %>%
  sample_n(size = 56) -> day2

day1 %>%
  mutate(index = c(0:27, 0:27), objPosition = gl(n = 2, k = 28, labels = c('first', 'second'))) %>%
  pivot_wider(values_from = value, names_from = objPosition) -> day1.objects

day2 %>%
  mutate(index = c(0:27, 0:27), objPosition = gl(n = 2, k = 28, labels = c('first', 'second'))) %>%
  pivot_wider(values_from = value, names_from = objPosition) -> day2.objects

bind_rows(day1.objects, day2.objects, .id = 'day') -> select.objects

bind_cols(select.celebs, select.places, select.objects) %>%
  rename(day = day...1) %>%
  select(-matches('...[0-9]$')) -> experiment_data
write_csv(x = experiment_data, 'experiment_data.csv', na = "")
