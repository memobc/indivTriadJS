# check if this subject is to be excluded

# requirements ------------------------------------------------------------

library(tidyverse)

# load data ---------------------------------------------------------------

tidy.enc <- read_rds('tidy_enc.rds')
tidy.ret <- read_rds('tidy_ret.rds')
tidy.bds <- read_rds('tidy_bds.rds')

# criterion 1 -------------------------------------------------------------
# participants who are statistical outliers (3 standard deviations below the mean)
# for reaction time for any 1 of our tasks


