import numpy as np

def analyze_surface_curvature():
    """Calculates eigenvalues from the second-order polynomial coefficients."""
    
    # 1. Extract the specific coefficients from your equation:
    # y = 79.94 + 0.995*x1 + 0.515*x2 - 1.376*x1^2 - 1.001*x2^2 + 0.25*x1*x2
    
    b11 = -1.376  # Coefficient for x1^2
    b22 = -1.001  # Coefficient for x2^2
    b12 = 0.250   # Coefficient for x1*x2
    
    # 2. Construct the B Matrix
    # CRITICAL STEP: The off-diagonal elements must be exactly HALF of b12.
    off_diagonal = b12 / 2
    
    B_matrix = np.array([
        [b11,          off_diagonal],
        [off_diagonal, b22         ]
    ])
    
    print("-" * 40)
    print(" THE 'B' MATRIX ")
    print("-" * 40)
    print(B_matrix)
    print("\n")
    
    # 3. Compute the Eigenvalues
    # np.linalg.eigvals solves the determinant equation |B - λI| = 0
    eigenvalues = np.linalg.eigvals(B_matrix)
    
    print("-" * 40)
    print(" CANONICAL ANALYSIS (Eigenvalues) ")
    print("-" * 40)
    
    for i, lambda_val in enumerate(eigenvalues, start=1):
        print(f"λ{i} = {lambda_val:.4f}")
        
    print("\n")
    print("-" * 40)
    print(" CONCLUSION ")
    print("-" * 40)
    
    # 4. Interpret the geometric shape based on the signs of λ
    if np.all(eigenvalues < 0):
        print("Surface Shape: MAXIMUM")
        print("Reasoning: All eigenvalues are negative (surface curves down in all directions).")
    elif np.all(eigenvalues > 0):
        print("Surface Shape: MINIMUM")
        print("Reasoning: All eigenvalues are positive (surface curves up in all directions).")
    else:
        print("Surface Shape: SADDLE POINT")
        print("Reasoning: Eigenvalues have mixed signs.")

if __name__ == "__main__":
    analyze_surface_curvature()