# Python Math Cheatsheet for STAT 514

Use this with the virtual environment in this folder:

```bash
cd midterms/midterm3
source .venv/bin/activate
python
```

Recommended imports:

```python
import math
import itertools
import numpy as np
from scipy import stats
```

## 1. Combinatorics

### Combinations and permutations

```python
math.comb(8, 2)      # C(8, 2) = 28
math.perm(8, 2)      # P(8, 2) = 56
math.factorial(5)    # 120
```

Common DOE uses:

```python
k = 8
n_main_effects = math.comb(k, 1)
n_two_factor_interactions = math.comb(k, 2)
n_three_factor_interactions = math.comb(k, 3)
n_all_effects = 2**k - 1
```

### Generate factor names / interactions

```python
factors = ["A", "B", "C", "D"]

for order in range(1, len(factors) + 1):
    for combo in itertools.combinations(factors, order):
        print("".join(combo))
```

Output:

```text
A B C D AB AC AD BC BD CD ABC ABD ACD BCD ABCD
```

### Number of aliases in a fractional factorial

For a \(2^{k-p}\) design:

```python
p = 5
aliases_besides_itself = 2**p - 1
```

## 2. Arrays and Matrices with NumPy

### Create vectors and matrices

```python
y = np.array([98, 72, 87, 85], dtype=float)

X = np.array([
    [1, -1, -1],
    [1,  1, -1],
    [1, -1,  1],
    [1,  1,  1],
], dtype=float)
```

### Basic operations

```python
X.T              # transpose
X @ X.T          # matrix multiplication
X.T @ X          # X'X
np.dot(y, y)     # dot product
np.sum(y)        # sum
np.mean(y)       # average
np.var(y, ddof=1)  # sample variance, denominator n-1
np.std(y, ddof=1)  # sample standard deviation
```

Important: use `@` for matrix multiplication, not `*`.

```python
A * B   # elementwise multiplication
A @ B   # matrix multiplication
```

## 3. Matrix Inverse, Solve, Least Squares

### Inverse

```python
XtX = X.T @ X
XtX_inv = np.linalg.inv(XtX)
```

Use inverse for formulas, but for numerical work prefer `solve` or `lstsq`.

### Solve linear system

For \(Ax=b\):

```python
solution = np.linalg.solve(A, b)
```

For normal equations:

```python
beta = np.linalg.solve(X.T @ X, X.T @ y)
```

### Least squares directly

For \(y=X\beta+\varepsilon\):

```python
beta, residual_ss_array, rank, singular_values = np.linalg.lstsq(X, y, rcond=None)
```

Compute fitted values and residuals:

```python
y_hat = X @ beta
residuals = y - y_hat
SSE = residuals @ residuals
df_error = len(y) - rank
MSE = SSE / df_error
```

### Hat matrix

```python
H = X @ np.linalg.inv(X.T @ X) @ X.T
y_hat = H @ y
residuals = (np.eye(len(y)) - H) @ y
```

## 4. Eigenvalues and Response Surface Classification

For second-order RSM:

\[
\hat y = \beta_0 + x'b + x'Bx.
\]

Build \(B\). Diagonal entries are pure quadratic coefficients. Off-diagonal entries are half the interaction coefficient.

Example:

\[
\hat y = 8 + 4x_1 - 2x_2 - 2x_1^2 - x_2^2.
\]

```python
b = np.array([4, -2], dtype=float)
B = np.array([
    [-2, 0],
    [0, -1],
], dtype=float)
```

Stationary point:

\[
x_s = -\frac{1}{2}B^{-1}b.
\]

```python
x_s = -0.5 * np.linalg.solve(B, b)
```

Predicted response:

```python
beta0 = 8
y_s = beta0 + x_s @ b + x_s @ B @ x_s
```

Eigenvalues:

```python
eigenvalues = np.linalg.eigvals(B)
```

Classification:

```python
if np.all(eigenvalues < 0):
    print("maximum")
elif np.all(eigenvalues > 0):
    print("minimum")
else:
    print("saddle")
```

## 5. t Tests and p-values

Use `scipy.stats`.

```python
from scipy import stats
```

### Critical values

For upper-tail critical value \(t_{\alpha,\nu}\):

```python
alpha = 0.05
df = 10
tcrit_upper = stats.t.ppf(1 - alpha, df)
```

For two-sided 5% test, use \(t_{\alpha/2,\nu}\):

```python
tcrit_two_sided = stats.t.ppf(1 - alpha / 2, df)
```

### One-sided p-values

Right-tail test:

\[
H_1:\theta>0.
\]

```python
t0 = 2.4
p_right = stats.t.sf(t0, df)      # P(T >= t0)
```

Left-tail test:

\[
H_1:\theta<0.
\]

```python
t0 = -2.4
p_left = stats.t.cdf(t0, df)      # P(T <= t0)
```

### Two-sided p-value

\[
H_1:\theta\ne 0.
\]

```python
t0 = -2.4
p_two = 2 * stats.t.sf(abs(t0), df)
```

Decision:

```python
alpha = 0.05
reject = p_two < alpha
```

## 6. F Tests and p-values

### F critical value

```python
alpha = 0.05
df1 = 2
df2 = 27
fcrit = stats.f.ppf(1 - alpha, df1, df2)
```

### F p-value

F-tests are upper-tail tests:

```python
F0 = 90
p_value = stats.f.sf(F0, df1, df2)
```

Decision:

```python
reject = p_value < alpha
```

## 7. Normal Distribution

### Standard normal critical values

```python
zcrit_two_sided = stats.norm.ppf(0.975)  # 1.95996
zcrit_upper_5 = stats.norm.ppf(0.95)     # 1.64485
```

### Normal p-values

```python
z0 = -2.09
p_two = 2 * stats.norm.sf(abs(z0))
p_left = stats.norm.cdf(z0)
p_right = stats.norm.sf(z0)
```

## 8. Confidence Intervals

### Generic t interval

\[
\hat\theta \pm t_{\alpha/2,df}SE(\hat\theta).
\]

```python
estimate = -13.75
se = 2.0
df = 2
alpha = 0.05

tcrit = stats.t.ppf(1 - alpha / 2, df)
ci = (estimate - tcrit * se, estimate + tcrit * se)
```

### Difference of two means, equal variance

```python
ybar1 = 16.76
ybar2 = 17.04
s1_sq = 0.100
s2_sq = 0.061
n1 = n2 = 10

sp_sq = ((n1 - 1) * s1_sq + (n2 - 1) * s2_sq) / (n1 + n2 - 2)
sp = math.sqrt(sp_sq)
se = sp * math.sqrt(1 / n1 + 1 / n2)
t0 = (ybar1 - ybar2) / se
df = n1 + n2 - 2
p_two = 2 * stats.t.sf(abs(t0), df)
```

### Welch two-sample t-test

```python
se = math.sqrt(s1_sq / n1 + s2_sq / n2)
t0 = (ybar1 - ybar2) / se

df = (s1_sq / n1 + s2_sq / n2)**2 / (
    (s1_sq / n1)**2 / (n1 - 1) + (s2_sq / n2)**2 / (n2 - 1)
)
p_two = 2 * stats.t.sf(abs(t0), df)
```

## 9. Factorial Effects in \(2^k\) Designs

### Effect from signs

For coded signs \(-1,+1\):

\[
\widehat{\text{effect}}_T = \frac{2}{N}\sum s_T y.
\]

Example for \(2^3\):

```python
design = np.array([
    [-1, -1, -1],
    [ 1, -1, -1],
    [-1,  1, -1],
    [ 1,  1, -1],
    [-1, -1,  1],
    [ 1, -1,  1],
    [-1,  1,  1],
    [ 1,  1,  1],
], dtype=float)

y = np.array([98, 72, 87, 85, 99, 79, 87, 80], dtype=float)

A_sign = design[:, 0]
B_sign = design[:, 1]
C_sign = design[:, 2]
AB_sign = A_sign * B_sign

A_effect = 2 * np.dot(A_sign, y) / len(y)
AB_effect = 2 * np.dot(AB_sign, y) / len(y)
```

Regression coefficients in coded variables:

```python
beta_A = A_effect / 2
beta_AB = AB_effect / 2
```

### Build all effects automatically

```python
factor_names = ["A", "B", "C"]

for order in range(1, len(factor_names) + 1):
    for idxs in itertools.combinations(range(len(factor_names)), order):
        name = "".join(factor_names[i] for i in idxs)
        signs = np.prod(design[:, idxs], axis=1)
        effect = 2 * np.dot(signs, y) / len(y)
        print(name, effect, "beta =", effect / 2)
```

## 10. ANOVA Table Calculations

### One-way ANOVA from treatment groups

```python
groups = [
    np.array([10, 12, 11], dtype=float),
    np.array([15, 14, 16], dtype=float),
    np.array([13, 12, 14], dtype=float),
]

a = len(groups)
N = sum(len(g) for g in groups)
grand_mean = np.mean(np.concatenate(groups))

SS_trt = sum(len(g) * (np.mean(g) - grand_mean)**2 for g in groups)
SSE = sum(np.sum((g - np.mean(g))**2) for g in groups)
SST = SS_trt + SSE

df_trt = a - 1
df_error = N - a
MS_trt = SS_trt / df_trt
MSE = SSE / df_error
F0 = MS_trt / MSE
p_value = stats.f.sf(F0, df_trt, df_error)
```

### Two-factor balanced ANOVA df

For \(a\) levels of \(A\), \(b\) levels of \(B\), \(n\) replicates per cell:

```python
a = 3
b = 3
n = 4

df_A = a - 1
df_B = b - 1
df_AB = (a - 1) * (b - 1)
df_error = a * b * (n - 1)
df_total = a * b * n - 1
```

## 11. Curvature Test with Center Points

For a factorial design plus center points:

\[
SS_{\text{curv}}=
\frac{n_F n_C}{n_F+n_C}(\bar y_F-\bar y_C)^2.
\]

```python
factorial_y = np.array([54, 47, 32, 45], dtype=float)
center_y = np.array([40, 38, 42], dtype=float)

nF = len(factorial_y)
nC = len(center_y)

ybarF = np.mean(factorial_y)
ybarC = np.mean(center_y)

MSE_pure = np.sum((center_y - ybarC)**2) / (nC - 1)
SS_curv = (nF * nC / (nF + nC)) * (ybarF - ybarC)**2
F0 = SS_curv / MSE_pure
p_value = stats.f.sf(F0, 1, nC - 1)
```

Equivalent t-test:

```python
se = math.sqrt(MSE_pure * (1 / nC + 1 / nF))
t0 = (ybarC - ybarF) / se
p_two = 2 * stats.t.sf(abs(t0), nC - 1)
```

## 12. CCD Helpers

### Total runs

```python
k = 5
nF = 2**(5 - 1)
nC = 3
N = nF + 2 * k + nC
```

### Rotatable alpha

\[
\alpha=n_F^{1/4}.
\]

```python
alpha = nF ** 0.25
```

### Generate CCD points for \(k=2\)

```python
alpha = math.sqrt(2)

factorial = np.array([
    [-1, -1],
    [ 1, -1],
    [-1,  1],
    [ 1,  1],
], dtype=float)

axial = np.array([
    [ alpha, 0],
    [-alpha, 0],
    [0,  alpha],
    [0, -alpha],
], dtype=float)

center = np.zeros((3, 2))

ccd_points = np.vstack([factorial, axial, center])
```

## 13. statsmodels OLS and ANOVA

Useful if you want R-like regression/ANOVA in Python.

```python
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
```

### Regression

```python
df = pd.DataFrame({
    "y": [98, 72, 87, 85, 99, 79, 87, 80],
    "A": [-1, 1, -1, 1, -1, 1, -1, 1],
    "B": [-1, -1, 1, 1, -1, -1, 1, 1],
})

fit = smf.ols("y ~ A + A:B", data=df).fit()
print(fit.summary())
```

### ANOVA table

```python
anova_table = sm.stats.anova_lm(fit, typ=2)
print(anova_table)
```

### Categorical factors

Use `C(name)` for categorical predictors:

```python
fit = smf.ols("y ~ C(treatment)", data=df).fit()
anova_table = sm.stats.anova_lm(fit, typ=2)
```

Two-factor with interaction:

```python
fit = smf.ols("y ~ C(A) * C(B)", data=df).fit()
anova_table = sm.stats.anova_lm(fit, typ=2)
```

## 14. Quick Critical Values

```python
def tcrit_two_sided(alpha, df):
    return stats.t.ppf(1 - alpha / 2, df)

def t_p_two_sided(t0, df):
    return 2 * stats.t.sf(abs(t0), df)

def fcrit(alpha, df1, df2):
    return stats.f.ppf(1 - alpha, df1, df2)

def f_p_value(F0, df1, df2):
    return stats.f.sf(F0, df1, df2)
```

Example:

```python
tcrit_two_sided(0.05, 2)  # 4.30265
fcrit(0.05, 1, 2)         # 18.5128
```

## 15. Common Mistakes

- Use `stats.t.sf(abs(t0), df) * 2` for two-sided t-tests.
- Use `stats.f.sf(F0, df1, df2)` for F-tests; F-tests are upper-tail.
- Use `ddof=1` for sample variance and sample standard deviation.
- Use `@` for matrix multiplication.
- In \(x'Bx\), off-diagonal \(B_{ij}\) is half the coefficient of \(x_ix_j\).
- For coded two-level factorials, regression coefficient equals effect divided by 2.
- Do not include center points when estimating factorial effects from \(-1,+1\) signs; use them for pure error and curvature.
