# Create backwards digit span json data

# requirements ------------------------------------------------------------

# <3
library(tidyverse)

# body --------------------------------------------------------------------
# We need to generate a random series of digits

set.seed(123)

## Day 1
digits.list <- vector("list")
c <- 0
for(i in rep(3:7, each = 2)){
  c <- c + 1;
  sample.int(n = 9, size = i, replace = TRUE) %>% 
    as.numeric() -> stimulus
  tibble(stimulus) -> tmp
  
  tmp %>%
    mutate(stimulus = str_c("<p style='font-size:48px'>", stimulus, "</p>")) -> tmp
  
  digits.list[[c]] <- tmp
}

jsonlite::write_json(digits.list, path = 'backwards_digit_span_day1.json', pretty = T)

## Day 2
digits.list <- vector("list")
c <- 0
for(i in rep(3:7, each = 2)){
  c <- c + 1;
  sample.int(n = 9, size = i, replace = TRUE) %>% 
    as.numeric() -> stimulus
  tibble(stimulus) -> tmp
  
  tmp %>%
    mutate(stimulus = str_c("<p style='font-size:48px'>", stimulus, "</p>")) -> tmp
  
  digits.list[[c]] <- tmp
}

jsonlite::write_json(digits.list, path = 'backwards_digit_span_day2.json', pretty = T)
