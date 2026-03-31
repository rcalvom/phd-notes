#Unreplicated FFD

set.seed(2026)

###########################################################################
## 1) Full 2^4 design, one run per cell
###########################################################################

des <- expand.grid(A = c(-1, 1), B = c(-1, 1), C = c(-1, 1), D = c(-1, 1))

## optional physical levels, just to mimic your earlier style
des$A_lev <- ifelse(des$A == -1, 8, 12)
des$B_lev <- ifelse(des$B == -1, 2, 5)
des$C_lev <- ifelse(des$C == -1, 40, 60)
des$D_lev <- ifelse(des$D == -1, 100, 140)

## true model:
## keep main effects, and include some nonzero 2-factor interactions
## so Resolution III will suffer from aliasing with 2FIs
beta <- c(
  mu  = 75,
  A   = 5,
  B   = 0,
  C   = 6,
  D   = 4,
  AB  = 3,
  AC  = -2,
  AD  = 0,
  BC  = 2.5,
  BD  = 0,
  CD  = 0,
  ABC = 0,
  ABD = 0,
  ACD = 0,
  BCD = 0,
  ABCD = 0
)

X <- model.matrix(~ A*B*C*D, des)
eta <- as.vector(X %*% beta)
Y   <- eta + rnorm(nrow(des), 0, 1)

full_dat <- data.frame(
  A = des$A,
  B = des$B,
  C = des$C,
  D = des$D,
  Y = Y,
  eta = eta
)

###########################################################################
## 2) Two 8-run half fractions 
###########################################################################

## Resolution IV: D = A*B*C   -> I = ABCD
idx_R4 <- with(des, D == A * B * C)
dat_R4 <- full_dat[idx_R4, ]

## Resolution III: D = A*B    -> I = ABD
idx_R3 <- with(des, D == A * B)
dat_R3 <- full_dat[idx_R3, ]

cat("Resolution IV runs:\n")
print(dat_R4)

cat("\nResolution III runs:\n")
print(dat_R3)

###########################################################################
## 3) Fit main-effects models on each fraction
###########################################################################

fit_R4 <- lm(Y ~ A + B + C + D, data = dat_R4)
fit_R3 <- lm(Y ~ A + B + C + D, data = dat_R3)

cat("\nResolution IV fit:\n")
print(summary(fit_R4))
print(coef(fit_R4))

cat("\nResolution III fit:\n")
print(summary(fit_R3))
print(coef(fit_R3))

###########################################################################
## 4) Compare estimated main effects to the true main effects
###########################################################################

true_main <- beta[c("mu", "A", "B", "C", "D")]

est_R4 <- coef(fit_R4)[c("(Intercept)", "A", "B", "C", "D")]
est_R3 <- coef(fit_R3)[c("(Intercept)", "A", "B", "C", "D")]


cat("\nTrue main-effect coefficients:\n")
print(true_main)

cat("\nEstimated main effects from Resolution IV:\n")
print(est_R4)

cat("\nEstimated main effects from Resolution III:\n")
print(est_R3)

mse_coef_R4 <- mean((est_R4 - true_main)^2)
mse_coef_R3 <- mean((est_R3 - true_main)^2)

cat("\nMSE of estimated main-effect coefficients:\n")
cat("Resolution IV =", mse_coef_R4, "\n")
cat("Resolution III =", mse_coef_R3, "\n")



###########################################################################
## 5) Repeated simulation: compare estimators of main effects
###########################################################################

true_main <- beta[c("mu", "A", "B", "C", "D")]

one_run_compare <- function(sd_eps = 1) {
  Y_tmp <- eta + rnorm(length(eta), 0, sd_eps)
  
  dat_R4_tmp <- data.frame(
    A = des$A[idx_R4],
    B = des$B[idx_R4],
    C = des$C[idx_R4],
    D = des$D[idx_R4],
    Y = Y_tmp[idx_R4]
  )
  
  dat_R3_tmp <- data.frame(
    A = des$A[idx_R3],
    B = des$B[idx_R3],
    C = des$C[idx_R3],
    D = des$D[idx_R3],
    Y = Y_tmp[idx_R3]
  )
  
  fit_R4_tmp <- lm(Y ~ A + B + C + D, data = dat_R4_tmp)
  fit_R3_tmp <- lm(Y ~ A + B + C + D, data = dat_R3_tmp)
  
  est_R4_tmp <- coef(fit_R4_tmp)[c("(Intercept)", "A", "B", "C", "D")]
  est_R3_tmp <- coef(fit_R3_tmp)[c("(Intercept)", "A", "B", "C", "D")]
  
  names(est_R4_tmp)[1] <- "mu"
  names(est_R3_tmp)[1] <- "mu"
  
  c(
    mu_R4 = est_R4_tmp["mu"],
    A_R4  = est_R4_tmp["A"],
    B_R4  = est_R4_tmp["B"],
    C_R4  = est_R4_tmp["C"],
    D_R4  = est_R4_tmp["D"],
    
    mu_R3 = est_R3_tmp["mu"],
    A_R3  = est_R3_tmp["A"],
    B_R3  = est_R3_tmp["B"],
    C_R3  = est_R3_tmp["C"],
    D_R3  = est_R3_tmp["D"],
    
    mse_R4 = mean((est_R4_tmp - true_main)^2),
    mse_R3 = mean((est_R3_tmp - true_main)^2)
  )
}

set.seed(2026)
res <- replicate(100, one_run_compare(sd_eps = 1))
res <- t(res)

boxplot(res[, "mse_R4"], res[, "mse_R3"],
        names = c("Resolution IV", "Resolution III"),
        ylab = "MSE of main-effect estimators",
        main = "Repeated simulation: estimator comparison")

