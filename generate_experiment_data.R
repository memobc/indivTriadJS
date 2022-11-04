# generate experiment data csv

# requirements
library(tidyverse)

# body
files <- list.files('Nina_similar_famous_faces_noBR/', pattern = '*.png')

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
files <- list.files('All/', pattern = '*.jpg')

# remove the tail end of the file name; find unique entries; split into
# first and last names; make a data frame
files %>%
  str_remove(string = ., pattern = '[12].jpg') %>%
  unique() -> place.names

# fix select names by hand
case_when(place.names == 'Winecellar' ~ 'Wine Cellar',
          place.names == 'Waitingroom' ~ 'Waiting Room',
          place.names == 'Windfarm' ~ 'Wind Farm',
          place.names == 'Stonehouse' ~ 'Stone House',
          place.names == 'Powerstation' ~ 'Power Station',
          place.names == 'Parking' ~ 'Parking Lot',          
          place.names == 'RedDoor' ~ 'Red Door',
          place.names == 'Mri' ~ 'MRI',
          place.names == 'IndoorTennis' ~ 'Indoor Tennis Court',          
          place.names == 'IndoorPool' ~ 'Indoor Pool',
          place.names == 'Icerink' ~ 'Ice Rink',          
          place.names == 'Greenhouse' ~ 'Green House',
          place.names == 'Ferriswheel' ~ 'Ferris Wheel',
          place.names == 'DiningRoom' ~ 'Dining Room',
          place.names == 'Checkin' ~ 'Check-in',
          place.names == 'Basketball' ~ 'Basketball Court',
          place.names == 'Bowling' ~ 'Bowling Alley',
          place.names == 'Conference' ~ 'Conference Room',
          place.names == 'Cruise' ~ 'Cruise Ship',
          place.names == 'Golf' ~ 'Golf Course',
          place.names == 'Groceries' ~ 'Grocery Store',
          place.names == 'Lecture' ~ 'Lecture Hall',
          place.names == 'Living' ~ 'Living Room',
          place.names == 'Lockers' ~ 'Locker Room',
          place.names == 'Tennis' ~ 'Tennis Court',
          place.names == 'Bed' ~ 'Bedroom',
          place.names == 'Bath' ~ 'Bathroom',           
          TRUE ~ place.names) -> place.names

# remove select places by hand
place.names %>%
  str_subset(., 'Balloon', negate = TRUE) %>%
  str_subset(., 'Camping', negate = TRUE) %>%
  str_subset(., 'Check-in', negate = TRUE) %>%
  str_subset(., 'Computer', negate = TRUE) %>%
  str_subset(., 'Crane', negate = TRUE) %>%
  str_subset(., 'Dance', negate = TRUE) %>%
  str_subset(., 'Entrance', negate = TRUE) %>%
  str_subset(., 'Lifeguard', negate = TRUE) %>%
  str_subset(., 'Racecourse', negate = TRUE) %>%
  str_subset(., 'Red Door', negate = TRUE) %>%
  str_subset(., 'Path', negate = TRUE) %>%
  str_subset(., 'Sail', negate = TRUE) %>%
  str_subset(., 'Ski', negate = TRUE) %>%
  str_subset(., 'Surf', negate = TRUE) %>%
  str_subset(., 'Winter', negate = TRUE) %>%
  str_subset(., 'Aisle', negate = TRUE) -> place.names

# objects -----------------------------------------------------------------

# body
df <- read_csv(file = 'BOSS_norms_maureen_condensed.csv')

# arrange by name agreement, only non-living objects
df %>% 
  arrange(desc(NameAgreement)) %>% 
  filter(Living == 'Non-Living') %>%
  head(n = 100) %>%
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

set.seed(123)
celeb.names %>%
  sample_n(size = 24) %>%
  mutate(last = str_replace_na(last, replacement = ''),
         people = str_c(first, last, sep = ' '),
         people = str_trim(people)) %>%
  select(-first, -last) -> people

set.seed(123)
place.names %>%
  as_tibble() %>%
  sample_n(size = 24) %>%
  rename(place = value) -> place

set.seed(123)
object.names %>%
  as_tibble() %>%
  sample_n(size = 48) %>%
  mutate(index = c(0:23, 0:23), objPosition = gl(n = 2, k = 24, labels = c('first', 'second'))) %>%
  pivot_wider(values_from = value, names_from = objPosition) -> objects

bind_cols(people, place, objects) -> experiment_data

write_csv(x = experiment_data, 'experiment_data.csv')