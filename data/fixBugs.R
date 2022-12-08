fixBugs <- function(){
  # manually fix bugs introduced into the experiment
  require(tidyverse)
  files <- list.files(pattern = '11-[78].*_experiment_data.csv', path = './')
  for(i in files){
    df <- read_csv(i)
    df$day <- 'two'
    # overwrite
    write_csv(df, i)
  }
}
