# Needs: library(pracma)
#install.packages("pracma")
library(pracma)

find_alpha_weak <- function(overall_alpha, n_segments, alpha_strong) { # Use numerical search to find the appropriate alpha_weak value
  # that will produce the desired overall_alpha level for the indicated
  # values of n_segments and alpha_strong.
  compute_error <- function(try_aw) {
    diff <- try_aw - alpha_strong
    diff_accumulated <- diff^(n_segments - 1)
    alpha_strong*(1-diff_accumulated)/(1-diff)+
      try_aw*diff_accumulated-overall_alpha
  }
  aw_range <- c(alpha_strong, overall_alpha^(1/n_segments))
  final_aw <- fzero(compute_error, aw_range)
  out      <- c(final_aw$x, final_aw$fval)
  return(out)
}

# Example:
find_alpha_weak(overall_alpha = 0.05, n_segments = 4, alpha_strong = 0.035) %>%
  magrittr::extract(1) %>%
  format(scientific = F, digits = 3)
