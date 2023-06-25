independentModel_BaCa <- function(x){

  x %>%
    dplyr::select(where(~!any(is.na(.x)))) %>%
    pivot_wider(id_cols = encTrialNum, names_from = ret_probe_pos, values_from = ends_with('Correct')) %>%
    summarise(across(-encTrialNum, mean)) %>%
    as_vector() -> probs

  Pba <- probs[1]
  Pca <- probs[2]

  upperLeft <- Pba*Pca
  lowerLeft <- Pba*(1-Pca)
  upperRight <- Pca*(1-Pba)
  lowerRight <- (1-Pba)*(1-Pca)

  daMatrix   <- matrix(c(upperLeft, lowerLeft, upperRight, lowerRight), nrow = 2, ncol = 2)
  rownames(daMatrix) <- str_c(names(Pba), c(TRUE, FALSE))
  colnames(daMatrix) <- str_c(names(Pca), c(TRUE, FALSE))

  return(tibble(TABS = list(daMatrix), Pba, Pba.name = names(Pba), Pca, Pca.name = names(Pca)))

}
