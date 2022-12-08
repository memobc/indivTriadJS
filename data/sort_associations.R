sort_associations <- function(x){
  if(x$RetKeyType == 'object'){
    type <- 'object-object'
  } else {
    type <- str_extract(x$RetKeyType, '(person)|(place)')
    x %>% 
      select(starts_with('resp_opt')) %>%
      as.list() -> resp_options
    if(x$objOne %in% resp_options){
      type <- str_c(type, '-objOne')
    } else if(x$objTwo %in% resp_options){
      type <- str_c(type, '-objTwo')
    }
  }
  return(type)
}