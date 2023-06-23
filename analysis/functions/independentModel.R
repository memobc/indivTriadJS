independentModel <- function(x){

  x %>%
    dplyr::select(where(~!all(is.na(.x)))) %>%
    mutate(across(ends_with('Correct'), as.logical)) %>%
    summarise(across(ends_with('Correct'), mean)) %>%
    as_vector() -> probs
  
  Pab <- probs[1]
  Pac <- probs[2]
  
  upperLeft <- Pab*Pac
  lowerLeft <- Pab*(1-Pac)
  upperRight <- Pac*(1-Pab)
  lowerRight <- (1-Pab)*(1-Pac)
  
  return(matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2))

}
