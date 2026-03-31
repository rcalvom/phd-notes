## Question 2(c)

###########################################################################
## 1) Enter the treatment labels and responses from the problem
###########################################################################

runs <- c("e", "ad", "cd", "bde", "ab", "bc", "ace", "abcde")
y <- c(23.2, 16.9, 23.8, 16.8, 15.5, 16.2, 23.4, 18.1)
factors <- c("A", "B", "C", "D", "E")

label_to_levels <- function(label, factors) {
  lev <- rep(-1, length(factors))
  names(lev) <- factors

  high_fac <- toupper(strsplit(label, "")[[1]])
  lev[high_fac] <- 1
  lev
}

X_fac <- t(sapply(runs, label_to_levels, factors = factors))

dat <- data.frame(
  run = runs,
  y = y,
  X_fac,
  row.names = NULL,
  check.names = FALSE
)

cat("Design table:\n")
print(dat)

###########################################################################
## 2) Estimate the main effects
###########################################################################

main_alias <- c(
  A = "A = CE = BCD = ABDE",
  B = "B = DE = ACD = ABCE",
  C = "C = AE = ABD = BCDE",
  D = "D = BE = ABC = ACDE",
  E = "E = AC = BD = ABCDE"
)

high_means <- sapply(factors, function(f) mean(dat$y[dat[[f]] == 1]))
low_means <- sapply(factors, function(f) mean(dat$y[dat[[f]] == -1]))
contrasts <- sapply(factors, function(f) sum(dat[[f]] * dat$y))

## usual factorial effect estimate = mean at high level - mean at low level
main_effects <- high_means - low_means

## regression coefficients with coded {-1, +1} levels are half of the effects
beta_hat <- main_effects / 2

q2c_out <- data.frame(
  factor = factors,
  alias = unname(main_alias[factors]),
  mean_high = unname(high_means),
  mean_low = unname(low_means),
  contrast = unname(contrasts),
  main_effect = unname(main_effects),
  beta_hat = unname(beta_hat),
  row.names = NULL,
  check.names = FALSE
)

cat("\nEstimated main effects:\n")
print(q2c_out)

###########################################################################
## 3) Check with a main-effects regression fit
###########################################################################

fit_main <- lm(y ~ A + B + C + D + E, data = dat)

cat("\nMain-effects regression coefficients:\n")
print(coef(fit_main))
