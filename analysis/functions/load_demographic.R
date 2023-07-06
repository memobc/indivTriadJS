load_demographic <- function(d){
  
  require(tidyverse)
  
  # list the full path to all files starting with "prolific_export" in the directory "d"
  list.files(path = d, pattern = 'prolific_export.*.csv', full.names = T) -> f.dem
  
  # grab all of the alphanumeric characters between the strings "export_" and ".csv"
  str_extract(f.dem, '(?<=export_).*(?=.csv)') -> extracted.study.id
  
  # using the read_csv function, read each csv file in "f.dem" in. Store as a list.
  df.dem <- map(f.dem, read_csv, show_col_types = F)
  
  # create a tibble with a study_id and dem.data column. dem.data column is a list-col.
  tibble(study_id = extracted.study.id, dem.data = df.dem) %>%
    unnest(cols = dem.data) -> df.dem
  
}