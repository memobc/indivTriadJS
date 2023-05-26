library(lavaan)
library(tidyverse)
library(corrr)
library(ppcor)
library(psych)

# TRIADs Key Test Simulations

compare_mats <- function(x, y){
  # computes the correlation between two square matrices
  require(pracma)
  return(cor(squareform(x), squareform(y), method = 'spearman'))
 }

null_perm_test <- function(myData, hyp){
  # run a null permutation test. return the results like pcor.test
  estimate <- compare_mats(1-cor(myData), hyp)
  Method   <- 'spearman'
  
  # 100 null sims
  nsims <- 100
  nullSim <- vector()
  for(i in 1:nsims){
    # randomly shuffle each column of the dataframe?
    myData %>%
      mutate(across(everything(), sample)) -> tmp
    nullSim[i] <- compare_mats(1-cor(tmp), hyp)
  }
  p.value <- 1-cume_dist(c(nullSim, estimate)) %>% magrittr::extract2(length(.))

  return(tibble(estimate, p.value, Method, nsims))

}

## Generate Data
# 
# 
#
# specify population model
population.model <- ' f1 =~ 0.5*personSes1 + 0.5*personSes2 
                      f2 =~ 0.5*placeSes1 + 0.5*placeSes2
                      f3 =~ 0.5*placeSes1 + 0.5*personSes1
                      f4 =~ 0.5*placeSes2 + 0.5*personSes2
                      f1 ~~ .65*f2
                    '
#set.seed(1234)
nS     <- 60
myData <- simulateData(population.model, sample.nobs=nS, standardized = TRUE)

## what does the correlation matrix look like?
myData %>%
  correlate() %>%
  corrr::shave(upper = F) %>%
  stretch(remove.dups = F, na.rm = T) %>%
  mutate(r = round(r, digits = 2)) %>%
  ggplot(aes(x = x, y = y, fill = r)) +
  geom_tile() +
  geom_label(aes(label = r), fill = 'white', color = 'black') +
  scale_x_discrete(limits = rev(c('personSes1', 'personSes2',  'placeSes1', 'placeSes2'))) +
  scale_y_discrete(limits = c('personSes1', 'personSes2',  'placeSes1', 'placeSes2')) +
  scale_fill_gradient2() +
  theme_light() +
  theme(panel.grid = element_blank()) %>%
  print()

# RSA like appraoch

(hyp <- matrix(data = c(0,0,1,1,
                        0,0,1,1,
                        1,1,0,0,
                        1,1,0,0), nrow = 4, ncol = 4))

null_perm_test(myData, hyp)

# partial correlation approach

pcor.test(myData$personSes1, myData$personSes2, myData[,c("placeSes1", "placeSes2")])
pcor.test(myData$placeSes1, myData$placeSes2, myData[,c("personSes1", "personSes2")])

# multiple R tests approach

r.test(n = nS, r12 = 0.33, r13 = 0.44, r23 = 0.22)

r.test(n = nS, r12 = 0.5, r13 = 0.16, r23 = 0.22)

r.test(n = nS, r12 = 0.5, r13 = 0.16, r23 = 0.22)

r.test(n = nS, r12 = 0.5, r13 = 0.16, r23 = 0.22)
