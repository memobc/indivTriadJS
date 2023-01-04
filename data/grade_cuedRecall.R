grade_cuedRecall <- function(x){
  
  responses <- c(x$Q0, x$Q1)
  
  if(x$key_ret == x$objOne){
    objOneCorrect <- NA
  } else {
    objOneCorrect <- any(agrepl(pattern = x$objOne, responses, max.distance = list(cost = 0.3), fixed = TRUE, ignore.case = TRUE))
  }
  
  if(x$key_ret == x$objTwo){
    objTwoCorrect <- NA
  } else {
    objTwoCorrect <- any(agrepl(pattern = x$objTwo, responses, max.distance = list(cost = 0.3), fixed = TRUE, ignore.case = TRUE))
  }
  
  if(x$key_ret == x$key_enc){
    keyCorrect <- NA
  } else {
    keyCorrect <- any(agrepl(pattern = x$key_enc, responses, max.distance = list(cost = 0.3), fixed = TRUE, ignore.case = TRUE))
  }
  
  return(tibble(objOneCorrect, objTwoCorrect, keyCorrect))

}
