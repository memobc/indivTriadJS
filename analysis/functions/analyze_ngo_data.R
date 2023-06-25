library(tidyverse)

# Ngo et al. 2021's data
df <- read_csv('~/Downloads/pspc_data_v2.csv')

# a script for calculating indep model retrieval dependency the correct way
calcuate_joinedRetreival <- function(Pab, Pac){
  
  upperLeft  <- Pab*Pac
  lowerLeft  <- Pab*(1-Pac)
  upperRight <- Pac*(1-Pab)
  lowerRight <- (1-Pab)*(1-Pac)
  
  daMatrix   <- matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2)
  
  joinedRetrieval <- daMatrix[1,1] + daMatrix[2,2]
  
  return(joinedRetrieval)
  
}

# apply this to their data and recalculate dependency
df %>%
  dplyr::select(ID, PC_Accuracy, 
                Ab_Accuracy, Ac_Accuracy, Ba_Accuracy, 
                Bc_Accuracy, Ca_Accuracy, Cb_Accuracy, 
                Collapsed_Data) %>%
  mutate(joinedRetrieval_AbAc = map2_dbl(Ab_Accuracy, Ac_Accuracy, calcuate_joinedRetreival),
         joinedRetrieval_BaBc = map2_dbl(Ba_Accuracy, Bc_Accuracy, calcuate_joinedRetreival),
         joinedRetrieval_CaCb = map2_dbl(Ca_Accuracy, Cb_Accuracy, calcuate_joinedRetreival),
         joinedRetrieval_BaCa = map2_dbl(Ab_Accuracy, Ac_Accuracy, calcuate_joinedRetreival),
         joinedRetrieval_AbCb = map2_dbl(Ab_Accuracy, Ac_Accuracy, calcuate_joinedRetreival),
         joinedRetrieval_AcBc = map2_dbl(Ab_Accuracy, Ac_Accuracy, calcuate_joinedRetreival)) %>%
  rowwise() %>%
  mutate(Collapsed_Data_Independent = mean(c_across(starts_with('joinedRetrieval')))) %>%
  ungroup() %>%
  dplyr::select(-starts_with('joinedRetrieval')) %>%
  mutate(Kyles_Dependency = Collapsed_Data - Collapsed_Data_Independent) %>%
  filter(!is.na(Kyles_Dependency)) -> df

# plot performance alongside dependency
ggplot(df, aes(x = PC_Accuracy, y = Kyles_Dependency)) +
  geom_point() +
  geom_smooth(method = 'lm', formula = y ~ x + I(x^2)) +
  geom_vline(xintercept = 0.25, color = 'red', linetype = 'dotted') +
  labs(title = 'Ngo et al. 2021', subtitle = "Dependency Calculated Using Kyle's Independent Model Calculation.",
       caption = 'Dots = subjects. Red Dotted Line = Chance (1/4 or .25 or 25%).')
