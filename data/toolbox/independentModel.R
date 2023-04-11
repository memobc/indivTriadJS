independentModel <- function(x){

  x %>%
    select(where(~!all(is.na(.x)))) %>%
    select(-predictedProbCorrect) %>%
    mutate(across(ends_with('Correct'), as.logical)) %>%
    summarise(across(ends_with('correct'), mean)) %>%
    as_vector() -> probs
  
  Pab <- probs[1]
  Pac <- probs[2]
  
  upperLeft <- Pab*Pac
  lowerLeft <- Pab*(1-Pac)
  upperRight <- Pac*(1-Pab)
  lowerRight <- (1-Pab)*(1-Pac)
  
  return(matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2))

}