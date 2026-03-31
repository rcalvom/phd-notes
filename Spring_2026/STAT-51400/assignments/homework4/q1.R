## Question 1

set.seed(2026)

## 1) Choose a truth and simulation settings
beta <- c(10, 2, -1, 1.5)
names(beta) <- c("(Intercept)", "x1", "x2", "x1:x2")
sigma <- 1

r_vals <- c(1, 2, 5)
n_sim <- 5000

## 2) Design A table (coded levels)
desA <- expand.grid(x1 = c(-1, 1), x2 = c(-1, 1))
X_A <- model.matrix(~ x1 * x2, desA)

## 3) Run the simulation and store raw coefficient estimates
sim_out <- vector("list", length(r_vals))
names(sim_out) <- paste0("r=", r_vals)

for (j in seq_along(r_vals)) {
  r <- r_vals[j]
  N <- 4 * r

  beta_hat_A <- matrix(NA_real_, nrow = n_sim, ncol = length(beta))
  beta_hat_B <- matrix(NA_real_, nrow = n_sim, ncol = length(beta))
  colnames(beta_hat_A) <- names(beta)
  colnames(beta_hat_B) <- names(beta)

  for (i in seq_len(n_sim)) {
    ## Design A: replicated 2^2 factorial
    X_rep <- X_A[rep(seq_len(nrow(X_A)), each = r), ]
    datA <- data.frame(
      x1 = X_rep[, "x1"],
      x2 = X_rep[, "x2"]
    )
    datA$Y <- as.vector(X_rep %*% beta) + rnorm(N, 0, sigma)
    beta_hat_A[i, ] <- coef(lm(Y ~ x1 * x2, data = datA))

    ## Design B: random runs on [-1, 1]^2
    datB <- data.frame(
      x1 = runif(N, min = -1, max = 1),
      x2 = runif(N, min = -1, max = 1)
    )
    X_B <- model.matrix(~ x1 * x2, datB)
    datB$Y <- as.vector(X_B %*% beta) + rnorm(N, 0, sigma)
    beta_hat_B[i, ] <- coef(lm(Y ~ x1 * x2, data = datB))
  }

  sim_out[[j]] <- list(
    r = r,
    factorial = as.data.frame(beta_hat_A, check.names = FALSE),
    random = as.data.frame(beta_hat_B, check.names = FALSE)
  )
}

## 4) Peek at the simulated coefficient estimates
cat("\nFirst 5 coefficient estimates for Design A (Factorial), r = 1\n")
print(head(sim_out[["r=1"]]$factorial, 5))

cat("\nFirst 5 coefficient estimates for Design B (Random), r = 1\n")
print(head(sim_out[["r=1"]]$random, 5))

## 5) q1.a: empirical bias and variance for each coefficient under each design
summarize_coef <- function(est_df, true_beta, design_name, r) {
  est_mat <- as.matrix(est_df)

  data.frame(
    r = r,
    design = design_name,
    coefficient = colnames(est_mat),
    bias = colMeans(est_mat) - true_beta[colnames(est_mat)],
    variance = apply(est_mat, 2, var),
    row.names = NULL,
    check.names = FALSE
  )
}

q1a_out <- do.call(
  rbind,
  lapply(
    sim_out,
    function(obj) {
      rbind(
        summarize_coef(obj$factorial, beta, "Factorial", obj$r),
        summarize_coef(obj$random, beta, "Random", obj$r)
      )
    }
  )
)

print(q1a_out)

## 6) q1.b: explanation
q1b_out <- c(
  "Bias is approximately zero for both designs because the fitted OLS model matches the true mean model and the simulation errors have mean 0.",
  "Conditional on the design matrix X, OLS is unbiased, so E(beta_hat | X) = beta for both the factorial and random designs.",
  "The bias is only approximately zero in the table because we estimated it with a finite Monte Carlo sample of 5000 simulations.",
  "Variance is smaller under the factorial design because the coded levels {-1, +1} produce a balanced, orthogonal design.",
  "That orthogonality makes the columns of X nearly uncorrelated and gives a more stable (X'X)^(-1), which reduces the variance of the coefficient estimates.",
  "The random design is not exactly balanced or orthogonal in finite samples, so its X'X can be poorly conditioned, especially when r is small, which inflates variance."
)

cat("\nq1.b\n")
cat(paste0("- ", q1b_out, collapse = "\n"))
cat("\n")
