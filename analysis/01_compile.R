# compile data
# compile all available data into a single data frame

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

d      <- choose.dir(caption = 'Select Data Folder')

# experimental data

f.exp  <- list.files(path = d, pattern = '.*data-experiment.csv', full.names = T)

df.exp <- map_dfr(f.exp, read_csv, show_col_types = F)

write_rds(x = df.exp, file = 'compiled_experiment.rds')

# interaction data

f.int  <- list.files(path = d, pattern = '.*data-interaction.csv', full.names = T)

tibble(file = f.int) %>%
  mutate(data = map(file, read_csv, show_col_types = F),
         subject_id = str_extract(f.int, '(?<=sub-).*(?=_ses)'),
         session_id = str_extract(f.int, '(?<=ses-).*(?=_data)')) %>%
  select(-file) -> df.int

write_rds(x = df.int, file = 'compiled_interaction.rds')
