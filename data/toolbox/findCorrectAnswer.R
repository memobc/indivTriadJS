findCorrectAnswer <- function(x){
  require(tidyverse)
  objOne <- x$objOne
  objTwo <- x$objTwo
  key <- x$key_enc
  resp_opts <- x %>% select(resp_opt_1:resp_opt_6) %>% as.list()
  correctResponse <- which(resp_opts %in% objOne | resp_opts %in% objTwo | resp_opts %in% key)
  if(length(correctResponse) > 1){
    correctResponse <- NA
  } else if(length(correctResponse) == 0){
    correctResponse <- NA
  }
  return(correctResponse)
}