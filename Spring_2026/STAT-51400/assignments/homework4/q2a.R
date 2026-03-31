## Question 2(a)

###########################################################################
## 1) Enter the treatment labels and responses from the problem
###########################################################################

runs <- c("e", "ad", "cd", "bde", "ab", "bc", "ace", "abcde")
y <- c(23.2, 16.9, 23.8, 16.8, 15.5, 16.2, 23.4, 18.1)
factors <- c("A", "B", "C", "D", "E")

###########################################################################
## 2) Convert treatment labels to coded levels {-1, +1}
###########################################################################

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

cat("Design table from the treatment labels:\n")
print(dat)

###########################################################################
## 3) Verify the generators I = ACE and I = BDE
###########################################################################

dat$ACE <- with(dat, A * C * E)
dat$BDE <- with(dat, B * D * E)

cat("\nGenerator check:\n")
print(dat[, c("run", "A", "B", "C", "D", "E", "ACE", "BDE")])

cat("\nAre all ACE products equal to +1? ", all(dat$ACE == 1), "\n", sep = "")
cat("Are all BDE products equal to +1? ", all(dat$BDE == 1), "\n", sep = "")

if (all(dat$ACE == 1) && all(dat$BDE == 1)) {
  cat("\nVerified: the observed 8-run fraction satisfies I = ACE and I = BDE.\n")
}
