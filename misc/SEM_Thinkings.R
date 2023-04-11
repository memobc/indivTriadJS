# power analysis
library(semPower)
library(lavaan)
library(corrr)
library(corrplot)
library(tidyverse)
library(semPlot)

ap <- semPower(type = 'a-priori', effect = 0.08, effect.measure = 'RMSEA', alpha = .05, power = .80, df = 13)

summary(ap)

# Bifactor Model ----------------------------------------------------------

# define (true) population model
model.pop <- '
# define relations between factors and items in terms of loadings
f1 =~ .5*x1 + .5*x2 + .5*x3 + .5*x4
f2 =~ .5*x5 + .5*x6 + .5*x7 + .5*x8
f3 =~ .7*x1 + .7*x2 + .7*x3 + .7*x4 + .7*x5 + .7*x6 + .7*x7 + .7*x8
# define unique variances of the items to be equal to 1-loading^2,
# so that the loadings above are in a standardized metric
x1 ~~ .26*x1
x2 ~~ .26*x2
x3 ~~ .26*x3
x4 ~~ .26*x4
x5 ~~ .26*x5
x6 ~~ .26*x6
x7 ~~ .26*x7
x8 ~~ .26*x8
# define variances of f1 and f2 to be 1
f1 ~~ 1*f1
f2 ~~ 1*f2
f3 ~~ 1*f3
# define covariance (=correlation, because factor variances are 1)
# between the factors to be .9
f1 ~~ 0*f2
f1 ~~ 0*f3
f2 ~~ 0*f3
'

# population covariance matrix
fit <- sem(model.pop)

cov.pop <- fitted(fit)$cov

corrplot::corrplot(corr = cov.pop, type = 'lower', diag = T, number.digits = 2, addCoef.col = 'white')

# Correlated Subfactors Model ---------------------------------------------

# define (true) population model
model.pop <- '
# define relations between factors and items in terms of loadings
f1 =~ .7*x1 + .7*x2 + .7*x3 + .7*x4
f2 =~ .7*x5 + .7*x6 + .7*x7 + .7*x8
# define unique variances of the items to be equal to 1-loading^2,
# so that the loadings above are in a standardized metric
x1 ~~ .51*x1
x2 ~~ .51*x2
x3 ~~ .51*x3
x4 ~~ .51*x4
x5 ~~ .51*x5
x6 ~~ .51*x6
x7 ~~ .51*x7
x8 ~~ .51*x8
# define variances of f1 and f2 to be 1
f1 ~~ 1*f1
f2 ~~ 1*f2
# define covariance (=correlation, because factor variances are 1)
# between the factors to be .9
f1 ~~ .6*f2
'

# population covariance matrix
fit <- sem(model.pop)

cov.pop <- fitted(fit)$cov

corrplot::corrplot(corr = cov.pop, type = 'lower', diag = T, number.digits = 2, addCoef.col = 'white')

# Single Factor Model -----------------------------------------------------

# define (true) population model
model.pop <- '
# define relations between factors and items in terms of loadings
f1 =~ .7*x1 + .7*x2 + .7*x3 + .7*x4 + .7*x5 + .7*x6 + .7*x7 + .7*x8
# define unique variances of the items to be equal to 1-loading^2,
# so that the loadings above are in a standardized metric
x1 ~~ .51*x1
x2 ~~ .51*x2
x3 ~~ .51*x3
x4 ~~ .51*x4
x5 ~~ .51*x5
x6 ~~ .51*x6
x7 ~~ .51*x7
x8 ~~ .51*x8
# define variances of f1 and f2 to be 1
f1 ~~ 1*f1
'

# population covariance matrix
fit <- sem(model.pop)

cov.pop <- fitted(fit)$cov

corrplot::corrplot(corr = cov.pop, type = 'lower', diag = T, number.digits = 2, addCoef.col = 'white')

# Hierchical Model  -----------------------------------------------------

# define (true) population model
model.pop <- '
# define relations between factors and items in terms of loadings
f1 =~ .7*x1 + .7*x2 + .7*x3 + .7*x4
f2 =~ .7*x5 + .7*x6 + .7*x7 + .7*x8
f3 =~ .7*f1 + .7*f2
# define unique variances of the items to be equal to 1-loading^2,
# so that the loadings above are in a standardized metric
x1 ~~ .27*x1
x2 ~~ .27*x2
x3 ~~ .27*x3
x4 ~~ .27*x4
x5 ~~ .27*x5
x6 ~~ .27*x6
x7 ~~ .27*x7
x8 ~~ .27*x8
# define variances of f1 and f2 to be 1
f1 ~~ 1*f1
f2 ~~ 1*f2
f3 ~~ 1*f3
'

# population covariance matrix
fit <- sem(model.pop)

cov.pop <- round(fitted(fit)$cov, digits = 2)

corrplot::corrplot(corr = cov.pop, type = 'lower', diag = T, number.digits = 2, addCoef.col = 'white')
