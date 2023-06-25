library(tidyverse)

df <- read_csv('~/Downloads/pspc_data_v2.csv')

calcuate_joinedRetreival <- function(Pab, Pac){
  
  upperLeft  <- Pab*Pac
  lowerLeft  <- Pab*(1-Pac)
  upperRight <- Pac*(1-Pab)
  lowerRight <- (1-Pab)*(1-Pac)
  
  daMatrix   <- matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2)
  
  joinedRetrieval <- daMatrix[1,1] + daMatrix[2,2]
  
  return(joinedRetrieval)
  
}


df %>%
  dplyr::select(ID, Ab_Accuracy, Ac_Accuracy, Independent_model_Ab_Ac) %>%
  mutate(joinedRetrieval = map2_dbl(Ab_Accuracy, Ac_Accuracy, calcuate_joinedRetreival)) %>%
  view()

