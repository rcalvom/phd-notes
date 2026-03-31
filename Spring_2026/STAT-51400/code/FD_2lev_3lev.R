set.seed(2026)

###########################################################################
##
## Compare 2-level and 3-level full factorial designs with roughly similar
## run sizes, under the following six cases:
##
## 1. Truth = main only,           Fit = main only
## 2. Truth = main + interaction,  Fit = main + interaction
## 3. Truth = main + interaction,  Fit = main only
## 4. Truth = full quadratic,      Fit = full quadratic
## 5. Truth = full quadratic,      Fit = main only
## 6. Truth = full quadratic,      Fit = main + interaction
##
## We use:
## - 2-level full factorial in 2 factors, replicated twice: 8 runs
## - 3-level full factorial in 2 factors: 9 runs
###########################################################################
###########################################################################
## 1) Designs
###########################################################################

## 2-level full factorial in 2 factors, replicated twice: 8 runs
des2_base <- expand.grid(x1 = c(-1, 1), x2 = c(-1, 1))
des2 <- des2_base[rep(seq_len(nrow(des2_base)), each = 2), ]
rownames(des2) <- NULL

## 3-level full factorial in 2 factors: 9 runs
des3 <- expand.grid(x1 = c(-1, 0, 1), x2 = c(-1, 0, 1))
rownames(des3) <- NULL

des2
des3
nrow(des2)
nrow(des3)

###########################################################################
## 2) Truth models
###########################################################################

## main effects only
f_main <- function(x1, x2) {
  50 + 6*x1 - 4*x2
}

## main + interaction
f_main_int <- function(x1, x2) {
  50 + 6*x1 - 4*x2 + 5*x1*x2
}

## full quadratic
f_full_quad <- function(x1, x2) {
  50 + 6*x1 - 4*x2 + 5*x1*x2 + 7*x1^2 - 6*x2^2
}

###########################################################################
## 3) Fitted model formulas
###########################################################################

form_main <- y ~ x1 + x2
form_main_int <- y ~ x1 * x2
form_full_quad <- y ~ x1 * x2 + I(x1^2) + I(x2^2)


###########################################################################
## CASE 1: Truth = main only, Fit = main only
###########################################################################

set.seed(2026)

## generate one run of data
dat2_s1 <- des2
dat2_s1$mu_true <- with(dat2_s1, f_main(x1, x2))
dat2_s1$y <- dat2_s1$mu_true + rnorm(nrow(dat2_s1), 0, .1)

dat3_s1 <- des3
dat3_s1$mu_true <- with(dat3_s1, f_main(x1, x2))
dat3_s1$y <- dat3_s1$mu_true + rnorm(nrow(dat3_s1), 0, .1)

dat2_s1
dat3_s1

## fit model
fit2_s1 <- lm(form_main, data = dat2_s1)
fit3_s1 <- lm(form_main, data = dat3_s1)

## inspect coefficients and summaries
coef(fit2_s1)
coef(fit3_s1)

truth_s1 <- c(6, -4)

mse2_s1 <- mean((coef(fit2_s1)[-1] - truth_s1)^2)
mse3_s1 <- mean((coef(fit3_s1)[-1] - truth_s1)^2)

mse2_s1
mse3_s1


###########################################################################
## CASE 2: Truth = main + interaction, Fit = main + interaction
###########################################################################

set.seed(2026)

dat2_s2 <- des2
dat2_s2$mu_true <- with(dat2_s2, f_main_int(x1, x2))
dat2_s2$y <- dat2_s2$mu_true + rnorm(nrow(dat2_s2), 0, .1)

dat3_s2 <- des3
dat3_s2$mu_true <- with(dat3_s2, f_main_int(x1, x2))
dat3_s2$y <- dat3_s2$mu_true + rnorm(nrow(dat3_s2), 0, .1)

dat2_s2
dat3_s2

fit2_s2 <- lm(form_main_int, data = dat2_s2)
fit3_s2 <- lm(form_main_int, data = dat3_s2)

coef(fit2_s2)
coef(fit3_s2)

truth_s2 <- c(6, -4, 5)
mse2_s2 <- mean((coef(fit2_s2)[-1] - truth_s2)^2)
mse3_s2 <- mean((coef(fit3_s2)[-1] - truth_s2)^2)

mse2_s2
mse3_s2


###########################################################################
## CASE 3: Truth = main + interaction, Fit = main only
###########################################################################

set.seed(2026)
 
dat2_s3 <- des2
dat2_s3$mu_true <- with(dat2_s3, f_main_int(x1, x2))
dat2_s3$y <- dat2_s3$mu_true + rnorm(nrow(dat2_s3), 0, .1)

dat3_s3 <- des3
dat3_s3$mu_true <- with(dat3_s3, f_main_int(x1, x2))
dat3_s3$y <- dat3_s3$mu_true + rnorm(nrow(dat3_s3), 0, .1)

dat2_s3
dat3_s3

fit2_s3 <- lm(form_main, data = dat2_s3)
fit3_s3 <- lm(form_main, data = dat3_s3)

coef(fit2_s3)
coef(fit3_s3)

truth_s3 <- c(6, -4)
mse2_s3 <- mean((coef(fit2_s3)[-1] - truth_s3)^2)
mse3_s3 <- mean((coef(fit3_s3)[-1] - truth_s3)^2)

mse2_s3
mse3_s3



###########################################################################
## CASE 4: Truth = full quadratic, Fit = full quadratic
###########################################################################

set.seed(2026)

dat2_s4 <- des2
dat2_s4$mu_true <- with(dat2_s4, f_full_quad(x1, x2))
dat2_s4$y <- dat2_s4$mu_true + rnorm(nrow(dat2_s4), 0, .1)

dat3_s4 <- des3
dat3_s4$mu_true <- with(dat3_s4, f_full_quad(x1, x2))
dat3_s4$y <- dat3_s4$mu_true + rnorm(nrow(dat3_s4), 0, .1)

dat2_s4
dat3_s4

fit2_s4 <- lm(form_full_quad, data = dat2_s4)
fit3_s4 <- lm(form_full_quad, data = dat3_s4)

coef(fit2_s4)
coef(fit3_s4)

truth_s4 <- c(6, -4, 5, 7, -6)
mse2_s4 <- mean((coef(fit2_s4)[-1] - truth_s4)^2)
mse3_s4 <- mean((coef(fit3_s4)[-1] - truth_s4)^2)

mse2_s4
mse3_s4


###########################################################################
## CASE 5: Truth = full quadratic, Fit = main only
###########################################################################

set.seed(2026)

dat2_s5 <- des2
dat2_s5$mu_true <- with(dat2_s5, f_full_quad(x1, x2))
dat2_s5$y <- dat2_s5$mu_true + rnorm(nrow(dat2_s5), 0, .1)

dat3_s5 <- des3
dat3_s5$mu_true <- with(dat3_s5, f_full_quad(x1, x2))
dat3_s5$y <- dat3_s5$mu_true + rnorm(nrow(dat3_s5), 0, .1)

dat2_s5
dat3_s5

fit2_s5 <- lm(form_main, data = dat2_s5)
fit3_s5 <- lm(form_main, data = dat3_s5)

coef(fit2_s5)
coef(fit3_s5)



truth_s5 <- c(6, -4)
mse2_s5 <- mean((coef(fit2_s5)[-1] - truth_s5)^2)
mse3_s5 <- mean((coef(fit3_s5)[-1] - truth_s5)^2)

mse2_s5
mse3_s5


###########################################################################
## CASE 6: Truth = full quadratic, Fit = main + interaction
###########################################################################

set.seed(2026)

dat2_s6 <- des2
dat2_s6$mu_true <- with(dat2_s6, f_full_quad(x1, x2))
dat2_s6$y <- dat2_s6$mu_true + rnorm(nrow(dat2_s6), 0, .1)

dat3_s6 <- des3
dat3_s6$mu_true <- with(dat3_s6, f_full_quad(x1, x2))
dat3_s6$y <- dat3_s6$mu_true + rnorm(nrow(dat3_s6), 0, .1)

dat2_s6
dat3_s6

fit2_s6 <- lm(form_main_int, data = dat2_s6)
fit3_s6 <- lm(form_main_int, data = dat3_s6)

coef(fit2_s6)
coef(fit3_s6)

truth_s6<- c(6, -4, 5)
mse2_s6 <- mean((coef(fit2_s6)[-1] - truth_s6)^2)
mse3_s6 <- mean((coef(fit3_s6)[-1] - truth_s6)^2)

mse2_s6
mse3_s6

###########################################################################
## 6-case one-run summary table
###########################################################################

###########################################################################
## Repeated simulation, still without helper functions
###########################################################################

B <- 100
sigma <- .1

res_s1 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s1) <- c("mse_2level", "mse_3level")

res_s2 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s2) <- c("mse_2level", "mse_3level")

res_s3 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s3) <- c("mse_2level", "mse_3level")

res_s4 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s4) <- c("mse_2level", "mse_3level")

res_s5 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s5) <- c("mse_2level", "mse_3level")

res_s6 <- matrix(NA, nrow = B, ncol = 2)
colnames(res_s6) <- c("mse_2level", "mse_3level")


set.seed(2026)

for (b in 1:B) {
  
  #########################################################################
  ## S1
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_main(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_main(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_main, data = dat2)
  fit3 <- lm(form_main, data = dat3)
  
  res_s1[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s1)^2)
  res_s1[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s1)^2)
  
  #########################################################################
  ## S2
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_main_int(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_main_int(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_main_int, data = dat2)
  fit3 <- lm(form_main_int, data = dat3)
  
  
  res_s2[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s2)^2)
  res_s2[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s2)^2)
  
  #########################################################################
  ## S3
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_main_int(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_main_int(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_main, data = dat2)
  fit3 <- lm(form_main, data = dat3)
  
  res_s3[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s3)^2)
  res_s3[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s3)^2)
  
  #########################################################################
  ## S4
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_full_quad(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_full_quad(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_full_quad, data = dat2)
  fit3 <- lm(form_full_quad, data = dat3)
  
  res_s4[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s4)^2)
  res_s4[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s4)^2)
  
  #########################################################################
  ## S5
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_full_quad(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_full_quad(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_main, data = dat2)
  fit3 <- lm(form_main, data = dat3)
  
  res_s5[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s5)^2)
  res_s5[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s5)^2)
  
  #########################################################################
  ## S6
  #########################################################################
  dat2 <- des2
  dat2$y <- with(dat2, f_full_quad(x1, x2) + rnorm(nrow(dat2), 0, sigma))
  
  dat3 <- des3
  dat3$y <- with(dat3, f_full_quad(x1, x2) + rnorm(nrow(dat3), 0, sigma))
  
  fit2 <- lm(form_main_int, data = dat2)
  fit3 <- lm(form_main_int, data = dat3)
  
  res_s6[b, "mse_2level"] <- mean((coef(fit2)[-1] - truth_s6)^2)
  res_s6[b, "mse_3level"] <- mean((coef(fit3)[-1] - truth_s6)^2)
}

###########################################################################
## Repeated simulation summary
###########################################################################

rep_tab <- data.frame(
  Scenario = c("S1", "S2", "S3", "S4", "S5", "S6"),
  Description = c(
    "Truth main only | Fit main only",
    "Truth main + interaction | Fit main + interaction",
    "Truth main + interaction | Fit main only",
    "Truth full quadratic | Fit full quadratic",
    "Truth full quadratic | Fit main only",
    "Truth full quadratic | Fit main + interaction"
  ),
  Mean_MSE_2level = c(
    mean(res_s1[, "mse_2level"]),
    mean(res_s2[, "mse_2level"]),
    mean(res_s3[, "mse_2level"]),
    mean(res_s4[, "mse_2level"]),
    mean(res_s5[, "mse_2level"]),
    mean(res_s6[, "mse_2level"])
  ),
  Mean_MSE_3level = c(
    mean(res_s1[, "mse_3level"]),
    mean(res_s2[, "mse_3level"]),
    mean(res_s3[, "mse_3level"]),
    mean(res_s4[, "mse_3level"]),
    mean(res_s5[, "mse_3level"]),
    mean(res_s6[, "mse_3level"])
  ),
  SD_MSE_2level = c(
    sd(res_s1[, "mse_2level"]),
    sd(res_s2[, "mse_2level"]),
    sd(res_s3[, "mse_2level"]),
    sd(res_s4[, "mse_2level"]),
    sd(res_s5[, "mse_2level"]),
    sd(res_s6[, "mse_2level"])
  ),
  SD_MSE_3level = c(
    sd(res_s1[, "mse_3level"]),
    sd(res_s2[, "mse_3level"]),
    sd(res_s3[, "mse_3level"]),
    sd(res_s4[, "mse_3level"]),
    sd(res_s5[, "mse_3level"]),
    sd(res_s6[, "mse_3level"])
  )
)

rep_tab

###########################################################################
## Repeated simulation boxplots
###########################################################################

par(mfrow = c(2, 3))

boxplot(res_s1[, "mse_2level"], res_s1[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S1", ylab = "MSE")
mtext("Truth main only | Fit main only", side = 3, line = 0.2, cex = 0.7)

boxplot(res_s2[, "mse_2level"], res_s2[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S2", ylab = "MSE")
mtext("Truth main + int | Fit main + int", side = 3, line = 0.2, cex = 0.7)

boxplot(res_s3[, "mse_2level"], res_s3[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S3", ylab = "MSE")
mtext("Truth main + int | Fit main only", side = 3, line = 0.2, cex = 0.7)

boxplot(res_s4[, "mse_2level"], res_s4[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S4", ylab = "MSE")
mtext("Truth full quad | Fit full quad", side = 3, line = 0.2, cex = 0.7)

boxplot(res_s5[, "mse_2level"], res_s5[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S5", ylab = "MSE")
mtext("Truth full quad | Fit main only", side = 3, line = 0.2, cex = 0.7)

boxplot(res_s6[, "mse_2level"], res_s6[, "mse_3level"],
        names = c("2-level", "3-level"),
        main = "S6", ylab = "MSE")
mtext("Truth full quad | Fit main + int", side = 3, line = 0.2, cex = 0.7)

par(mfrow = c(1, 1))