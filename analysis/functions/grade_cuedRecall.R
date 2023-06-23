grade_cuedRecall <- function(x){

  responses <- c(x$ret_resp_1, x$ret_resp_2)

  if(x$ret_probe == x$objOne){
    objOneCorrect <- NA
  } else {
    objOneCorrect <- any(agrepl(pattern = x$objOne, responses, max.distance = list(all = 0.3), fixed = TRUE, ignore.case = TRUE))
  }

  if(x$ret_probe == x$objTwo){
    objTwoCorrect <- NA
  } else {
    objTwoCorrect <- any(agrepl(pattern = x$objTwo, responses, max.distance = list(all = 0.3), fixed = TRUE, ignore.case = TRUE))
  }

  if(x$ret_probe == x$key){
    keyCorrect <- NA
  } else {

    if(x$condition == 'famous place'){
      keyCorrect <- any(agrepl(pattern = x$key, responses, max.distance = list(all = 0.65), fixed = TRUE, ignore.case = TRUE))
    } else {
      keyCorrect <- any(agrepl(pattern = x$key, responses, max.distance = list(all = 0.3), fixed = TRUE, ignore.case = TRUE))
    }

  }

  return(tibble(objOneCorrect, objTwoCorrect, keyCorrect))

}
