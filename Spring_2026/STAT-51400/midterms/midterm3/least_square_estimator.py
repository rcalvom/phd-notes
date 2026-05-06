import numpy as np

def fit_second_order_model():
    """Calculates the regression coefficients for a Central Composite Design."""
    
    # 1. Load the data directly from Table 11.6
    # x1, x2 are the coded variables. y is the yield.
    x1 = np.array([-1, -1, 1, 1, 0, 0, 0, 0, 0, 1.414, -1.414, 0, 0], dtype=float)
    x2 = np.array([-1, 1, -1, 1, 0, 0, 0, 0, 0, 0, 0, 1.414, -1.414], dtype=float)
    y = np.array([76.5, 77.0, 78.0, 79.5, 79.9, 80.3, 80.0, 79.7, 79.8, 78.4, 75.6, 78.5, 77.0], dtype=float)
    
    # 2. Construct the Design Matrix (X)
    # We need 6 columns: Intercept, x1, x2, x1^2, x2^2, x1*x2
    n = len(y)
    X = np.column_stack((
        np.ones(n),                  # beta_0 (Intercept)
        x1,                          # beta_1 (Linear x1)
        x2,                          # beta_2 (Linear x2)
        x1**2,                       # beta_11 (Quadratic x1)
        x2**2,                       # beta_22 (Quadratic x2)
        x1 * x2                      # beta_12 (Interaction x1*x2)
    ))

    # 3. Solve the Normal Equations: beta = (X^T * X)^-1 * X^T * y
    X_T = X.transpose()
    X_T_X_inv = np.linalg.inv(X_T.dot(X))
    X_T_y = X_T.dot(y)
    
    beta = X_T_X_inv.dot(X_T_y)
    
    # 4. Print the results
    print("-" * 50)
    print(" SECOND-ORDER MODEL COEFFICIENTS (CCD)")
    print("-" * 50)
    print(f"Intercept (b0):     {beta[0]:.3f}")
    print(f"Linear x1 (b1):     {beta[1]:.3f}")
    print(f"Linear x2 (b2):     {beta[2]:.3f}")
    print(f"Quadratic x1 (b11): {beta[3]:.3f}")
    print(f"Quadratic x2 (b22): {beta[4]:.3f}")
    print(f"Interaction (b12):  {beta[5]:.3f}")
    print("-" * 50)
    
    print("\nResulting Equation:")
    print(f"y_hat = {beta[0]:.2f} + {beta[1]:.3f}x1 + {beta[2]:.3f}x2 "
          f"{beta[3]:.3f}x1^2 {beta[4]:.3f}x2^2 + {beta[5]:.2f}x1x2")

if __name__ == "__main__":
    fit_second_order_model()
