extract_corr_answer <- function(x){
  # extract correct answer from bds presentation table
  corr_answer <- str_c(rev(x$stimulus), collapse = '')
  return(corr_answer)
}