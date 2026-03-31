set.seed(514)

# User-chosen parameter values for the simulation study.
beta_0 <- 1.0
beta_1 <- 2.0
beta_2 <- -1.5
beta_12 <- 0.75
sigma2 <- 1.0

r_values <- c(1, 2, 5)
n_sim <- 5000

generate_response <- function(x1, x2, beta_0, beta_1, beta_2, beta_12, sigma2) {
  mu <- beta_0 + beta_1 * x1 + beta_2 * x2 + beta_12 * x1 * x2
  mu + rnorm(length(x1), mean = 0, sd = sqrt(sigma2))
}

simulate_factorial_design <- function(r, beta_0, beta_1, beta_2, beta_12, sigma2) {
  design <- expand.grid(x1 = c(-1, 1), x2 = c(-1, 1))
  design <- design[rep(seq_len(nrow(design)), each = r), , drop = FALSE]
  design$y <- generate_response(
    x1 = design$x1,
    x2 = design$x2,
    beta_0 = beta_0,
    beta_1 = beta_1,
    beta_2 = beta_2,
    beta_12 = beta_12,
    sigma2 = sigma2
  )

  coef(lm(y ~ x1 * x2, data = design))
}

simulate_random_design <- function(r, beta_0, beta_1, beta_2, beta_12, sigma2) {
  n <- 4 * r
  design <- data.frame(
    x1 = runif(n, min = -1, max = 1),
    x2 = runif(n, min = -1, max = 1)
  )
  design$y <- generate_response(
    x1 = design$x1,
    x2 = design$x2,
    beta_0 = beta_0,
    beta_1 = beta_1,
    beta_2 = beta_2,
    beta_12 = beta_12,
    sigma2 = sigma2
  )

  coef(lm(y ~ x1 * x2, data = design))
}

collect_estimates <- function(r, n_sim, design_name, simulator) {
  estimates <- replicate(
    n = n_sim,
    expr = simulator(r, beta_0, beta_1, beta_2, beta_12, sigma2)
  )

  data.frame(
    design = design_name,
    r = r,
    sim = seq_len(n_sim),
    beta_0_hat = estimates["(Intercept)", ],
    beta_1_hat = estimates["x1", ],
    beta_2_hat = estimates["x2", ],
    beta_12_hat = estimates["x1:x2", ],
    row.names = NULL
  )
}

simulation_results <- do.call(
  rbind,
  unlist(
    lapply(
      r_values,
      function(r) {
        list(
          collect_estimates(r, n_sim, "A_factorial", simulate_factorial_design),
          collect_estimates(r, n_sim, "B_random", simulate_random_design)
        )
      }
    ),
    recursive = FALSE
  )
)

print(head(simulation_results))
