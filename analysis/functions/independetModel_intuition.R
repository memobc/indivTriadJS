# Lets build our intuition for how independent model estimates joined retrieval

calcuate_joinedRetreival <- function(Pab, Pac){
  
  upperLeft  <- Pab*Pac
  lowerLeft  <- Pab*(1-Pac)
  upperRight <- Pac*(1-Pab)
  lowerRight <- (1-Pab)*(1-Pac)
  
  daMatrix   <- matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2)
  
  joinedRetrieval <- daMatrix[1,1] + daMatrix[2,2]
  
  return(joinedRetrieval)
  
}

Pab <- seq(0,1,0.01)
Pac <- seq(0,1,0.01)

expand_grid(Pab,Pac) %>% 
  mutate(Indep_mode_AbAc = map2_dbl(Pab, Pac, calcuate_joinedRetreival)) -> df
  
ggplot(df, aes(x = Pab, y = Pac, fill = joinedRetrieval)) + 
  geom_raster() +
  scale_fill_distiller(type = 'div', palette = 5) +
  theme_minimal()