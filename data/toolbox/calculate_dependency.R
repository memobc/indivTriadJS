calculate_dependency <- function(df){
  # df is a subjects worth of data
  df %>%
    mutate(isCorrectQ1 = factor(isCorrectQ1, levels = c(T,F)),
           isCorrectQ1 = factor(isCorrectQ2, levels = c(T,F))) -> tmp
  

}