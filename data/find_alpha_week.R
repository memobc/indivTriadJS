# Needs: library(pracma)
install.packages("pracma")
library(pracma)
find_alpha_weak <- function(overall_alpha, n_segments, alpha_strong) { # Use numerical search to find the appropriate alpha_weak value
  # that will produce the desired overall_alpha level for the indicated
  # values of n_segments and alpha_strong.
  compute_error <- function(try_aw) {
    diff <- try_aw - alpha_strong
    diff_accumulated <- diffˆ(n_segments - 1)
    alpha_strong(1-diff_accumulated)/(1-diff)+
      try_awdiff_accumulated-overall_alpha
  }
  browser()
  aw_range < -c(alpha_strong, overall_alphaˆ(1/n_segments)) 
  final_aw <- fzero(compute_error, aw_range)
  out      <- c(final_aw$x, final_aw$fval)
  return(out)
}
# Example:
find_alpha_weak(0.05, 3, 0.01)
# should give the results 0.3390478 0.0000000