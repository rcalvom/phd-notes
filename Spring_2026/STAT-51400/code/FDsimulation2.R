## Unreplicated full factorial design

set.seed(2026)

## 1) One run per cell
des <- expand.grid(A = c(-1, 1), B = c(-1, 1), C = c(-1, 1))
des$A_lev <- ifelse(des$A==-1, 8, 12)   # kN
des$B_lev <- ifelse(des$B==-1, 2, 5)    # %
des$C_lev <- ifelse(des$C==-1, 40, 60)  # °C
beta <- c(mu = 75, A = 4, B = 0, C = 6, AB = 3, AC = -2, BC = 0, ABC = 0)
X <- model.matrix(~ A*B*C, des)
Y <- as.vector(X %*% beta) + rnorm(nrow(des), 0, 1)

dat1 <- data.frame(
  A = factor(des$A),
  B = factor(des$B),
  C = factor(des$C),
  Y = Y
)

## 2) Fit saturated model (no residual df); coefficients are contrasts
fit1 <- lm(Y ~ A*B*C, data = dat1)
anova(fit1)          # note: residual df = 0 (no F-tests)
coef(fit1)

## 3) Effects and half-normal plot

eff <- function(signs, y) mean(signs * y)  # half-effect
effs <- c(
  A=eff(des$A, Y), B=eff(des$B, Y), C=eff(des$C, Y),
  `A:B`=eff(des$A*des$B, Y), `A:C`=eff(des$A*des$C, Y), `B:C`=eff(des$B*des$C, Y),
  `A:B:C`=eff(des$A*des$B*des$C, Y)
)
abs_eff <- sort(abs(effs))
n  <- length(abs_eff)
p  <- ppoints(n, a = 0.5)
hn <- qnorm(0.5 + 0.5*p)   # half-normal quantiles (>= 0)

plot(abs_eff, hn,
     main = "Unreplicated 2^3: half-normal of effects",
     xlab = "|Effect|", ylab = "Half-normal quantiles", pch = 19)

## fit the reference line using only the smaller effects (robust to actives)
idx <- seq_len(n) <= floor(n/2)   # lower half assumed inactive
abline(lm(hn[idx] ~ abs_eff[idx]), lty = 2)

text(abs_eff, hn, labels = names(abs_eff), pos = 4, cex = 0.8)
###########################################################################

## --- build significant term set
active <- c("A", "C", "A:B", "A:C")
keep <- unique(active)
DF <- data.frame(Y = Y, as.data.frame(X[,active]))

## --- fit reduced model
fit2 <- aov(Y ~. , DF)
summary(fit2)        # ANOVA with residual df now available

fit3 <- lm(Y ~. , DF)
fit3

mean( (fit3$coef - beta[c("mu", "A", "C", "AB", "AC")])^2 )
