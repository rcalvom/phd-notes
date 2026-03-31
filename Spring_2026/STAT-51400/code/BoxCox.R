
set.seed(514)
df <- data.frame(
  y = c(rnorm(20, mean=3, sd=1), rnorm(20, mean=4, sd=1), rnorm(20, mean=5, sd=1)),
  g = gl(3, 20, labels = c("0","1","2"))
)


fit <- lm(y~g, df)

summary(fit)

anova(fit)

r  <- rstandard(fit) 
f  <- fitted(fit)
par(mfrow=c(3,2))
qqnorm(r, pch = 22, bg = "grey70",
       main = "Normal probability plot of residuals",
       xlab = "Theoretical quantiles", ylab = "Standardized residuals")
qqline(r, lwd = 2)
hist(df$y)

df$y1 <- exp(df$y)
fit1 <- lm(y1~g, df)
r1  <- rstandard(fit1) 
f1  <- fitted(fit1)

qqnorm(r1, pch = 22, bg = "grey70",
       main = "Normal probability plot of residuals",
       xlab = "Theoretical quantiles", ylab = "Standardized residuals")
qqline(r1, lwd = 2)
hist(df$y1)

df$y2 <- (df$y)^2
fit2 <- lm(y2~g, df)
r2  <- rstandard(fit2) 
f2  <- fitted(fit2)

qqnorm(r2, pch = 22, bg = "grey70",
       main = "Normal probability plot of residuals",
       xlab = "Theoretical quantiles", ylab = "Standardized residuals")
qqline(r2, lwd = 2)
hist(df$y2)

df$y3 <- sqrt(df$y)
fit3 <- lm(y3~g, df)
r3  <- rstandard(fit3) 
f3  <- fitted(fit3)

qqnorm(r3, pch = 22, bg = "grey70",
       main = "Normal probability plot of residuals",
       xlab = "Theoretical quantiles", ylab = "Standardized residuals")
qqline(r3, lwd = 2)
hist(df$y3)

df$y4 <- 1/(df$y+1)
fit4 <- lm(y4~g, df)
r4  <- rstandard(fit4) 
f4  <- fitted(fit4)

qqnorm(r4, pch = 22, bg = "grey70",
       main = "Normal probability plot of residuals",
       xlab = "Theoretical quantiles", ylab = "Standardized residuals")
qqline(r4, lwd = 2)
hist(df$y4)







