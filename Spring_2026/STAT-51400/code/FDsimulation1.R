## Replicated factorial design

set.seed(2026)

## 1) Design table (coded and natural levels), randomized run order
des <- expand.grid(A = c(-1, 1), B = c(-1, 1), C = c(-1, 1))
des$A_lev <- ifelse(des$A==-1, 8, 12)   # kN
des$B_lev <- ifelse(des$B==-1, 2, 5)    # %
des$C_lev <- ifelse(des$C==-1, 40, 60)  # °C

r <- 3                                   # replicates per cell
N <- nrow(des) * r

## 2) Simulate a truth 
beta <- c(mu = 75, A = 4, B = 0, C = 6, AB = 3, AC = -2, BC = 0, ABC = 0)
X <- model.matrix(~ A*B*C, des)                # effects-coded
X_rep <- X[rep(seq_len(nrow(X)), each = r), ]
sigma <- 1                                     # process noise SD
Y <- X_rep %*%beta + rnorm(N, 0, sigma)

## 3) Put together a data frame (factors, run order)
dat <- data.frame(X_rep[,2:4], Y = Y, row.names = NULL)

## 4) Fit full factorial model and show ANOVA
fit <- aov(Y ~ A*B*C, data = dat)
summary(fit)           # ANOVA table
coef(lm(Y ~ A*B*C, dat))  # coefficients (effects-coded with factor coding)

## 5) interaction plots (base R)

par(mfrow=c(1,3))
with(dat, interaction.plot(B, A, Y, fun=mean, main="A×B (averaged over C)",
                           xlab="Binder %", trace.label="Pressure"))
with(dat, interaction.plot(C, A, Y, fun=mean, main="A×C (averaged over B)",
                           xlab="Drying temp", trace.label="Pressure"))
with(dat, interaction.plot(C, B, Y, fun=mean, main="B×C (averaged over A)",
                           xlab="Drying temp", trace.label="Binder %"))
par(mfrow=c(1,1))


## --- build significant term set
active <- c("A", "C", "A:B", "A:C")
keep <- unique(active)
DF <- data.frame(as.data.frame(X_rep[,active]),Y = Y, row.names = NULL)

fit3 <- lm(Y ~. , DF)
fit3
mean( (fit3$coef - beta[c("mu", "A", "C", "AB", "AC")])^2 )


