# STAT 514 Course Summary

This is an open-book exam summary built from the course slides in `slides/`. It emphasizes reusable formulas, design choice rules, degrees of freedom, and model forms.

## 1. DOE Principles and Terminology

### Core vocabulary

- **Factor:** controllable or observed input variable that may affect the response.
- **Level:** one setting of a factor.
- **Treatment:** one factor level or one combination of factor levels.
- **Experimental unit:** smallest unit to which a treatment is independently applied.
- **Run:** one experimental trial.
- **Response:** measured output.
- **Nuisance factor:** variable not of direct scientific interest but likely to affect the response.
- **Design:** list or matrix of planned runs.

### Fundamental principles

- **Randomization:** randomize assignment and/or run order to protect against unknown nuisance variables and time trends.
- **Replication:** repeat independent experimental units at the same treatment to estimate experimental error and improve precision.
- **Blocking:** group homogeneous units by known nuisance factors, then randomize within blocks.

For factorial and fractional factorial interpretation, use:

- **Sparsity:** only a few effects are usually active.
- **Hierarchy:** lower-order effects are more likely important than higher-order effects.
- **Heredity:** interactions are more plausible when their parent main effects are active.

### Design choice quick rules

- Homogeneous units, one factor: **CRD**.
- Known nuisance factor and every treatment can be run in each block: **RCBD**.
- Two nuisance factors, same number of treatments/rows/columns: **Latin square**.
- Three nuisance factors with two orthogonal treatment systems: **Graeco-Latin square**.
- Cannot fit every treatment in every block but balanced co-occurrence is possible: **BIBD**.
- Many two-level factors and screening: **fractional factorial**.
- Need curvature/second-order model for quantitative factors: **CCD/RSM**.
- Deterministic computer simulator, expensive runs, high dimension: **space-filling design / Latin hypercube**.
- Hard-to-change and easy-to-change factors: **split-plot**.

## 2. Linear Model and Matrix Algebra

### Matrix model

For response vector \(y\), design matrix \(X\), parameter vector \(\beta\), and error \(\varepsilon\):

$$
y = X\beta + \varepsilon.
$$

Least squares minimizes

$$
SSE(\beta) = (y-X\beta)'(y-X\beta).
$$

Normal equations:

$$
X'X\hat\beta = X'y.
$$

If \(X'X\) is invertible,

$$
\hat\beta = (X'X)^{-1}X'y.
$$

Fitted values, hat matrix, and residuals:

$$
\hat y = X\hat\beta = Hy,\qquad
H = X(X'X)^{-1}X',\qquad
e = y-\hat y = (I-H)y.
$$

### Identifiability

- Full parameter identifiability requires \(X\) to have full column rank.
- If \(X'X\) is singular, the normal equations have infinitely many solutions.
- Near-collinearity makes \((X'X)^{-1}\) large and standard errors unstable.

### Normal-error inference

Assume

$$
\varepsilon_i \stackrel{iid}{\sim} N(0,\sigma^2),\qquad
\varepsilon \sim N(0,\sigma^2 I).
$$

Then

$$
\hat\beta \sim N\left(\beta,\sigma^2(X'X)^{-1}\right).
$$

Estimate error variance:

$$
\hat\sigma^2 = MSE = \frac{SSE}{n-p},
$$

where \(p\) is the number of fitted parameters including the intercept.

For coefficient \(i\):

$$
SE(\hat\beta_i)=\sqrt{MSE\cdot [(X'X)^{-1}]_{ii}}.
$$

Test one coefficient:

$$
H_0:\beta_i=0,\qquad
t_0=\frac{\hat\beta_i}{SE(\hat\beta_i)}\sim t_{n-p}.
$$

Confidence interval:

$$
\hat\beta_i \pm t_{\alpha/2,n-p}SE(\hat\beta_i).
$$

Overall regression:

$$
SST = SSR + SSE,\qquad
R^2 = \frac{SSR}{SST}=1-\frac{SSE}{SST}.
$$

For testing all non-intercept predictors:

$$
F_0=\frac{SSR/(p-1)}{SSE/(n-p)}.
$$

## 3. Simple Comparative Experiments

### Two-sample equal-variance t-test

For two treatments with sample means \(\bar y_1,\bar y_2\), sample variances \(s_1^2,s_2^2\), sizes \(n_1,n_2\), and equal variances:

$$
s_p^2=\frac{(n_1-1)s_1^2+(n_2-1)s_2^2}{n_1+n_2-2}.
$$

Test:

$$
H_0:\mu_1=\mu_2,\qquad
t_0=\frac{\bar y_1-\bar y_2}{s_p\sqrt{1/n_1+1/n_2}}
\sim t_{n_1+n_2-2}.
$$

CI for \(\mu_1-\mu_2\):

$$
(\bar y_1-\bar y_2)\pm t_{\alpha/2,n_1+n_2-2}s_p\sqrt{1/n_1+1/n_2}.
$$

### Welch unequal-variance t-test

$$
t_0=\frac{\bar y_1-\bar y_2}{\sqrt{s_1^2/n_1+s_2^2/n_2}},
$$

with approximate degrees of freedom

$$
\nu=
\frac{(s_1^2/n_1+s_2^2/n_2)^2}
{(s_1^2/n_1)^2/(n_1-1)+(s_2^2/n_2)^2/(n_2-1)}.
$$

### Paired comparison

For paired differences \(d_j=y_{Aj}-y_{Bj}\):

$$
\bar d=\frac{1}{n}\sum_{j=1}^n d_j,\qquad
s_d^2=\frac{\sum_{j=1}^n(d_j-\bar d)^2}{n-1}.
$$

Test:

$$
t_0=\frac{\bar d}{s_d/\sqrt n}\sim t_{n-1}.
$$

## 4. Categorical Predictors and One-Way ANOVA

### Categorical coding

For \(a\) factor levels:

- **Cell-means model:** \(y_{ij}=\mu_i+\varepsilon_{ij}\).
- **Effects model:** \(y_{ij}=\mu+\tau_i+\varepsilon_{ij}\), with \(\sum_i\tau_i=0\) in balanced designs.
- **Dummy coding:** one reference group; coefficients are differences from reference.
- **Effects/sum coding:** intercept is grand mean; coefficients are deviations from grand mean.
- **Orthogonal polynomial contrasts:** useful for ordered numeric levels, e.g. linear/quadratic trends.
- **Helmert contrasts:** compare each level to the mean of previous levels.

Predictions are invariant to coding, but coefficient interpretation changes.

### Completely randomized design (CRD)

Balanced one-factor model:

$$
y_{ij}=\mu+\tau_i+\varepsilon_{ij},
\qquad i=1,\ldots,a,\quad j=1,\ldots,n.
$$

Assume \(\varepsilon_{ij}\stackrel{iid}{\sim}N(0,\sigma^2)\).

Hypotheses:

$$
H_0:\mu_1=\cdots=\mu_a
\quad\Longleftrightarrow\quad
H_0:\tau_1=\cdots=\tau_a=0.
$$

Let \(N=\sum_i n_i\), \(\bar y_{i.}\) be treatment means, and \(\bar y_{..}\) be the grand mean.

Total sum of squares:

$$
SST=\sum_i\sum_j(y_{ij}-\bar y_{..})^2.
$$

Treatment sum of squares:

$$
SS_{\text{Trt}}=\sum_i n_i(\bar y_{i.}-\bar y_{..})^2.
$$

Error sum of squares:

$$
SSE=\sum_i\sum_j(y_{ij}-\bar y_{i.})^2.
$$

Partition:

$$
SST=SS_{\text{Trt}}+SSE.
$$

Degrees of freedom:

$$
df_T=N-1,\qquad df_{\text{Trt}}=a-1,\qquad df_E=N-a.
$$

Mean squares and F-test:

$$
MS_{\text{Trt}}=\frac{SS_{\text{Trt}}}{a-1},\qquad
MSE=\frac{SSE}{N-a},\qquad
F_0=\frac{MS_{\text{Trt}}}{MSE}.
$$

Reject equal treatment means if

$$
F_0>F_{\alpha,a-1,N-a}.
$$

### Model adequacy

Check residuals:

$$
e_{ij}=y_{ij}-\hat y_{ij}=y_{ij}-\bar y_{i.}.
$$

Use:

- Normal Q-Q plot for normality.
- Residuals vs fitted for constant variance.
- Residuals vs run order/time for independence.
- Residuals by treatment/block for hidden heterogeneity.

### Box-Cox response transformation

For strictly positive \(y\):

$$
y^{(\lambda)}=
\begin{cases}
\dfrac{y^\lambda-1}{\lambda}, & \lambda\ne 0,\\
\log y, & \lambda=0.
\end{cases}
$$

Use when residuals show skewness or nonconstant variance. Refit and recheck diagnostics.

### Randomization / permutation test

If normality is questionable, compute the reference distribution by permuting treatment labels. For observed statistic \(F_0\), approximate p-value:

$$
p=\frac{\#\{F^{(b)}\ge F_0\}}{B}.
$$

For exact enumeration with balanced groups of sizes \(n_1,\ldots,n_a\):

$$
K=\frac{N!}{n_1!\cdots n_a!}.
$$

## 5. Post-ANOVA Multiple Comparisons

### Fisher's LSD

For comparing treatments \(i\) and \(j\):

$$
t_0=\frac{|\bar y_{i.}-\bar y_{j.}|}
{\sqrt{MSE(1/n_i+1/n_j)}}.
$$

Reject if

$$
t_0>t_{\alpha/2,df_E}.
$$

Balanced design with \(n_i=n\):

$$
LSD=t_{\alpha/2,df_E}\sqrt{\frac{2MSE}{n}}.
$$

### Tukey HSD

Balanced design:

$$
q_0=\frac{|\bar y_{i.}-\bar y_{j.}|}{\sqrt{MSE/n}}.
$$

Reject if

$$
q_0>q_{\alpha}(a,df_E).
$$

HSD:

$$
HSD=q_{\alpha}(a,df_E)\sqrt{\frac{MSE}{n}}.
$$

Tukey-Kramer for unequal sample sizes:

$$
|\bar y_{i.}-\bar y_{j.}|>
q_{\alpha}(a,df_E)\sqrt{\frac{MSE}{2}\left(\frac{1}{n_i}+\frac{1}{n_j}\right)}.
$$

## 6. Blocking Designs

### Randomized complete block design (RCBD)

Use when there is one known nuisance factor and each block can receive all treatments.

Model with \(a\) treatments and \(b\) blocks:

$$
y_{ij}=\mu+\tau_i+\beta_j+\varepsilon_{ij},
\qquad i=1,\ldots,a,\quad j=1,\ldots,b.
$$

Constraints:

$$
\sum_i\tau_i=0,\qquad \sum_j\beta_j=0.
$$

Hypothesis for treatments:

$$
H_0:\tau_1=\cdots=\tau_a=0.
$$

Sums of squares:

$$
SST=\sum_i\sum_j(y_{ij}-\bar y_{..})^2.
$$

$$
SS_{\text{Trt}}=b\sum_i(\bar y_{i.}-\bar y_{..})^2.
$$

$$
SS_{\text{Blocks}}=a\sum_j(\bar y_{.j}-\bar y_{..})^2.
$$

$$
SSE=\sum_i\sum_j(y_{ij}-\bar y_{i.}-\bar y_{.j}+\bar y_{..})^2.
$$

Partition:

$$
SST=SS_{\text{Trt}}+SS_{\text{Blocks}}+SSE.
$$

Degrees of freedom:

$$
df_T=ab-1,\quad
df_{\text{Trt}}=a-1,\quad
df_{\text{Blocks}}=b-1,\quad
df_E=(a-1)(b-1).
$$

F-test for treatments:

$$
F_0=\frac{SS_{\text{Trt}}/(a-1)}{SSE/[(a-1)(b-1)]}.
$$

Estimates:

$$
\hat\mu=\bar y_{..},\qquad
\hat\tau_i=\bar y_{i.}-\bar y_{..},\qquad
\hat\beta_j=\bar y_{.j}-\bar y_{..}.
$$

Prediction and residual:

$$
\hat y_{ij}=\bar y_{i.}+\bar y_{.j}-\bar y_{..},\qquad
e_{ij}=y_{ij}-\hat y_{ij}.
$$

### Latin square design

Use to control two nuisance factors, rows and columns, with \(p\) treatments.

Each treatment appears once in each row and once in each column. Total runs:

$$
N=p^2.
$$

Model:

$$
y_{ijk}=\mu+\rho_i+\tau_j+\gamma_k+\varepsilon_{ijk},
$$

where \(\rho_i\) is row effect, \(\tau_j\) is treatment effect, and \(\gamma_k\) is column effect.

Degrees of freedom:

$$
df_T=p^2-1,\quad
df_{\text{Rows}}=p-1,\quad
df_{\text{Columns}}=p-1,\quad
df_{\text{Trt}}=p-1,
$$

$$
df_E=(p-1)(p-2).
$$

Sums of squares have form

$$
SS_{\text{Rows}}=p\sum_i(\bar y_{i..}-\bar y_{...})^2,
$$

$$
SS_{\text{Columns}}=p\sum_k(\bar y_{..k}-\bar y_{...})^2,
$$

$$
SS_{\text{Trt}}=p\sum_j(\bar y_{.j.}-\bar y_{...})^2.
$$

### Graeco-Latin square design

Use to control three nuisance/blocking factors or to handle two orthogonal treatment systems. For order \(p\), total runs:

$$
N=p^2.
$$

ANOVA decomposition:

$$
SST=SS_L+SS_G+SS_{\text{Rows}}+SS_{\text{Columns}}+SSE.
$$

Each source \(L,G,\) rows, columns has \(p-1\) df, so

$$
df_E=p^2-1-4(p-1)=(p-1)(p-3).
$$

### Balanced incomplete block design (BIBD)

Use when each block cannot contain all treatments.

Definitions:

- \(a\): treatments.
- \(b\): blocks.
- \(k\): treatments per block.
- \(r\): replications per treatment.
- \(\lambda\): number of times each pair of treatments occurs together.

Total observations:

$$
N=ar=bk.
$$

Pair balance:

$$
\lambda(a-1)=r(k-1),
\qquad
\lambda=\frac{r(k-1)}{a-1}.
$$

The BIBD model is block-adjusted:

$$
y_{ij}=\mu+\tau_i+\beta_j+\varepsilon_{ij},
$$

but not all \(i,j\) combinations are observed.

## 7. Factorial Designs

### Why factorial designs

Factorial designs run all combinations of factor levels. They estimate:

- Main effects.
- Interactions.
- Joint behavior that one-factor-at-a-time designs cannot estimate.

For factors \(A\) with \(a\) levels and \(B\) with \(b\) levels, one replicate has \(ab\) runs.

### Two-factor ANOVA with interaction

For \(a\) levels of \(A\), \(b\) levels of \(B\), and \(n\) replicates per cell:

$$
y_{ijk}=\mu+\alpha_i+\beta_j+(\alpha\beta)_{ij}+\varepsilon_{ijk}.
$$

Constraints:

$$
\sum_i\alpha_i=0,\qquad
\sum_j\beta_j=0,
$$

$$
\sum_i(\alpha\beta)_{ij}=0\ \text{for each }j,\qquad
\sum_j(\alpha\beta)_{ij}=0\ \text{for each }i.
$$

Degrees of freedom:

$$
df_A=a-1,\quad
df_B=b-1,\quad
df_{AB}=(a-1)(b-1),\quad
df_E=ab(n-1),\quad
df_T=abn-1.
$$

Sums of squares:

$$
SS_A=bn\sum_i(\bar y_{i..}-\bar y_{...})^2,
$$

$$
SS_B=an\sum_j(\bar y_{.j.}-\bar y_{...})^2,
$$

$$
SS_{AB}=n\sum_i\sum_j(\bar y_{ij.}-\bar y_{i..}-\bar y_{.j.}+\bar y_{...})^2,
$$

$$
SSE=\sum_i\sum_j\sum_k(y_{ijk}-\bar y_{ij.})^2.
$$

### Main effects and interactions in a \(2^2\)

Using treatment labels \((1),a,b,ab\) and \(n\) replicates:

$$
A=\frac{ab+a-b-(1)}{2n},
$$

$$
B=\frac{ab+b-a-(1)}{2n},
$$

$$
AB=\frac{ab+(1)-a-b}{2n}.
$$

Equivalent definition:

$$
A=\bar y_{A+}-\bar y_{A-}.
$$

Interaction:

$$
AB=
\frac{1}{2}
\left[
(\bar y_{A+B+}-\bar y_{A-B+})
-
(\bar y_{A+B-}-\bar y_{A-B-})
\right].
$$

### \(2^k\) factorial designs

Number of treatment combinations:

$$
N_{\text{cells}}=2^k.
$$

With \(n\) replicates:

$$
N=2^k n.
$$

Number of effects excluding intercept:

$$
2^k-1.
$$

Breakdown:

$$
\binom{k}{1}\ \text{main effects},\quad
\binom{k}{2}\ \text{two-factor interactions},\quad
\ldots,\quad
\binom{k}{k}=1\ \text{k-factor interaction}.
$$

Each effect has 1 df.

If the full model is fit:

$$
df_E=2^k(n-1).
$$

With coded variables \(x_i\in\{-1,+1\}\), the full \(2^k\) regression model includes all products:

$$
y=\beta_0+\sum_i\beta_i x_i+\sum_{i<j}\beta_{ij}x_ix_j+\cdots+\beta_{12\cdots k}x_1\cdots x_k+\varepsilon.
$$

In an orthogonal \(2^k\) design:

$$
\hat\beta_{\text{term}}=\frac{\widehat{\text{effect}}_{\text{term}}}{2}.
$$

General contrast/effect formula for a term \(T\):

$$
\widehat{\text{effect}}_T=
\bar y_{T+}-\bar y_{T-}
=\frac{1}{2^{k-1}n}\sum_{\text{runs}} s_T y,
$$

where \(s_T\) is the product of coded signs for term \(T\).

Sum of squares for a \(2^k\) effect:

$$
SS_T=\frac{\left(\sum s_T y_{\text{total}}\right)^2}{2^k n}
=2^{k-2}n\left(\widehat{\text{effect}}_T\right)^2.
$$

For an unreplicated \(2^k\), there is no pure-error df if the full model is fit. Common strategies:

- Pool high-order interactions as error using hierarchy/sparsity.
- Use normal or half-normal plots of effects.

### Effect plots

- Main effect plot: treatment means versus factor levels.
- Interaction plot: conditional means; nonparallel lines indicate interaction.
- Positive interaction/synergy: combined effect larger than additive expectation.
- Negative interaction/antagonism: combined effect smaller than additive expectation.

## 8. Fractional Factorial Designs

### Basic notation

A \(2^{k-p}\) design has:

$$
N=2^{k-p}
$$

runs for \(k\) two-level factors, using a \(1/2^p\) fraction of the full \(2^k\).

There are \(k-p\) independent/basic factors and \(p\) generated/dependent factors.

### Generators and defining relation

Example:

$$
D=ABC.
$$

Multiply both sides by \(D\):

$$
I=ABCD.
$$

This word is part of the **defining relation**.

For \(p\) independent generators, the complete defining relation contains:

$$
2^p
$$

words including \(I\), so there are \(2^p-1\) nonidentity defining words.

Each effect has an alias set of size \(2^p\), meaning it is aliased with \(2^p-1\) other effects.

Aliases are found by multiplying an effect by every word in the defining relation. Example with \(I=ABC\):

$$
A \cdot I=A,\qquad
A\cdot ABC=BC,
$$

so

$$
A=BC.
$$

### Resolution

Resolution is the length of the shortest nonidentity word in the complete defining relation.

- **Resolution III:** main effects may be aliased with two-factor interactions.
- **Resolution IV:** main effects are not aliased with two-factor interactions; two-factor interactions may be aliased with each other.
- **Resolution V:** main effects are not aliased with two-factor or three-factor interactions; two-factor interactions may be aliased with three-factor interactions.

Rule:

A design has resolution \(R\) if no \(p\)-factor effect is aliased with another effect containing fewer than \(R-p\) factors.

### Practical selection

Use maximum resolution when choosing among possible fractional factorial designs. For screening:

- Use resolution III only if main effects are the main goal and interactions are assumed negligible.
- Prefer resolution IV when possible for screening main effects with some protection against two-factor interactions.
- Prefer resolution V if two-factor interactions must be estimated clearly.

## 9. Three-Level Factorial Designs

For \(k\) factors at three levels:

$$
N_{\text{cells}}=3^k.
$$

Levels may be coded as \(-1,0,+1\), \(0,1,2\), or \(1,2,3\).

For a 3-level factor:

$$
df_{\text{main effect}}=3-1=2.
$$

For two 3-level factors:

$$
df_{AB}=(3-1)(3-1)=4.
$$

A \(3^2\) full factorial has:

$$
9\ \text{runs per replicate},\qquad
df_{\text{model}}=8\ \text{excluding intercept}.
$$

With \(n\) replicates:

$$
N=9n,\qquad df_E=9(n-1).
$$

For numerical factors, 3-level designs can estimate curvature through linear and quadratic components.

## 10. Response Surface Methodology (RSM)

### Purpose

RSM is used to optimize a response over quantitative factors.

Sequential strategy:

1. Screen factors.
2. Run local experiment.
3. Fit low-order model.
4. Test for curvature.
5. If no curvature, move along steepest ascent/descent.
6. If curvature is present, fit a second-order model and optimize.

### Coding natural variables

For natural variable \(\xi_i\), center \(\xi_{i0}\), and step \(\Delta_i\):

$$
x_i=\frac{\xi_i-\xi_{i0}}{\Delta_i}.
$$

### First-order model

$$
\hat y=\hat\beta_0+\sum_{i=1}^k\hat\beta_i x_i.
$$

The gradient direction is:

$$
\nabla \hat y=(\hat\beta_1,\ldots,\hat\beta_k)'.
$$

For steepest ascent, move in direction \(+\nabla\hat y\). For steepest descent, move in direction \(-\nabla\hat y\).

If choosing \(\Delta x_1=c\), then

$$
\Delta x_i=c\frac{\hat\beta_i}{\hat\beta_1}.
$$

### Curvature check with center points

A factorial design plus center points can test curvature:

$$
SS_{\text{curv}}=
\frac{n_F n_C}{n_F+n_C}
\left(\bar y_F-\bar y_C\right)^2,
$$

where \(n_F\) is factorial runs and \(n_C\) is center runs.

Then

$$
F_{\text{curv}}=\frac{SS_{\text{curv}}/1}{MSE_{\text{pure error}}}.
$$

## 11. Central Composite Designs (CCD)

CCD is used to fit second-order models.

For \(k\) factors, a CCD consists of:

- \(n_F\) factorial or fractional factorial points.
- \(2k\) axial/star points.
- \(n_C\) center points.

Total runs:

$$
N=n_F+2k+n_C.
$$

Second-order model:

$$
\hat y=\hat\beta_0+\sum_{i=1}^k\hat\beta_i x_i+
\sum_{i=1}^k\hat\beta_{ii}x_i^2+
\sum_{i<j}\hat\beta_{ij}x_ix_j.
$$

Number of parameters in a full second-order model:

$$
p=1+k+k+\binom{k}{2}
=1+2k+\frac{k(k-1)}{2}.
$$

For \(k=2\):

$$
p=6.
$$

For \(k=3\):

$$
p=10.
$$

Axial distance:

- Spherical choice often sets axial points at radius \(\sqrt{k}\).
- Rotatable CCD:

$$
\alpha=n_F^{1/4}.
$$

For a full \(2^k\) factorial portion, \(n_F=2^k\), so

$$
\alpha=(2^k)^{1/4}=2^{k/4}.
$$

For \(k=2\), \(\alpha=\sqrt{2}\).

## 12. Optimization of Second-Order Response Surfaces

Write the second-order model in matrix form:

$$
\hat y=\hat\beta_0+x'b+x'Bx,
$$

where

$$
b=(\hat\beta_1,\ldots,\hat\beta_k)'.
$$

The symmetric matrix \(B\) has diagonal elements \(\hat\beta_{ii}\), and off-diagonal elements \(\hat\beta_{ij}/2\), because:

$$
x'Bx=\sum_i B_{ii}x_i^2+2\sum_{i<j}B_{ij}x_ix_j.
$$

Stationary point:

$$
\frac{\partial \hat y}{\partial x}=b+2Bx=0.
$$

If \(B\) is invertible:

$$
x_s=-\frac{1}{2}B^{-1}b.
$$

Predicted response at the stationary point:

$$
\hat y_s=\hat\beta_0+x_s'b+x_s'Bx_s.
$$

Canonical analysis:

Let \(\lambda_1,\ldots,\lambda_k\) be eigenvalues of \(B\). In canonical coordinates \(w_i\):

$$
\hat y=\hat y_s+\sum_{i=1}^k \lambda_i w_i^2.
$$

Classification:

- All \(\lambda_i<0\): local maximum.
- All \(\lambda_i>0\): local minimum.
- Mixed signs: saddle point.
- Larger \(|\lambda_i|\): stronger curvature/sensitivity in that canonical direction.

## 13. Random Effects

Use random effects when factor levels are sampled from a larger population and inference should generalize beyond observed levels.

Example random effects:

- Machines sampled from a fleet.
- Classrooms sampled from a school system.
- Patients with repeated measurements.

Simple random-intercept model:

$$
y_{ij}=\mu+\tau_i+b_j+\varepsilon_{ij},
$$

where treatment \(\tau_i\) may be fixed and group \(b_j\) is random:

$$
b_j\stackrel{iid}{\sim}N(0,\sigma_b^2),\qquad
\varepsilon_{ij}\stackrel{iid}{\sim}N(0,\sigma^2).
$$

Mean:

$$
E(y_{ij})=\mu+\tau_i.
$$

Variance:

$$
Var(y_{ij})=\sigma_b^2+\sigma^2.
$$

Covariance for observations in same group:

$$
Cov(y_{ij},y_{i'j})=\sigma_b^2.
$$

Correlation within group:

$$
\rho=\frac{\sigma_b^2}{\sigma_b^2+\sigma^2}.
$$

Observations in different groups are independent under the usual model.

If variance components are known and covariance matrix is \(V\), generalized least squares:

$$
\hat\beta=(X'V^{-1}X)^{-1}X'V^{-1}y.
$$

## 14. Split-Plot Designs

Use split plots when some factors are hard to change and full randomization is impractical.

- **Whole plots:** receive hard-to-change factor \(A\).
- **Subplots:** receive easy-to-change factor \(B\) within whole plots.
- Randomization is restricted: randomize \(A\) to whole plots, then \(B\) within whole plots.

Basic model:

$$
y_{ijk}=\mu+\alpha_i+w_{k(i)}+\beta_j+(\alpha\beta)_{ij}+\varepsilon_{ijk},
$$

where \(w_{k(i)}\) is whole-plot error and \(\varepsilon_{ijk}\) is subplot error.

Variance structure:

$$
w_{k(i)}\sim N(0,\sigma_w^2),\qquad
\varepsilon_{ijk}\sim N(0,\sigma^2).
$$

Observations in the same whole plot are correlated:

$$
Cov(y,y')=\sigma_w^2,\qquad
Corr(y,y')=\frac{\sigma_w^2}{\sigma_w^2+\sigma^2}.
$$

Important testing rule:

- Test whole-plot factor \(A\) against whole-plot error.
- Test subplot factor \(B\) and \(AB\) against subplot error.

## 15. Computer Experiments

Computer experiments use deterministic or stochastic simulators instead of physical experiments.

Physical experiments usually emphasize treatment comparison, randomization, replication, and error estimation.

Computer experiments usually emphasize:

- Prediction over an input region.
- Emulator/surrogate modeling.
- Optimization.
- Sensitivity analysis.
- Space-filling coverage.

For deterministic simulators:

- Replication at identical input settings is usually wasteful.
- Randomization is usually less important.
- Space-filling is more important than classical factorial precision.

### Emulator idea

Simulator:

$$
y=f(x).
$$

Emulator:

$$
\hat f(x)\approx f(x),
$$

learned from limited simulator runs.

Gaussian-process surrogate:

$$
Y(x)=m(x)+Z(x),
$$

where \(Z(x)\) is a stationary Gaussian process with covariance kernel \(K(x,x')\).

## 16. Space-Filling Designs

For \(n\) points \(x_1,\ldots,x_n\in[0,1]^d\), the goal is:

- Good global coverage.
- Avoid clustering.
- Avoid large empty regions.

### Maximin criterion

Maximize the minimum pairwise distance:

$$
\max_D\ \min_{i<j} d(x_i,x_j).
$$

Interpretation: keep design points far apart; avoid clustering.

### Minimax criterion

Minimize the maximum distance from any candidate/input point to the nearest design point:

$$
\min_D\ \max_{x\in\mathcal X}\ \min_i d(x,x_i).
$$

Interpretation: control the largest uncovered hole.

### Latin hypercube design (LHD)

For \(n\) runs and \(k\) factors:

- Divide each factor's range into \(n\) equal intervals.
- Place exactly one design point in each interval for each one-dimensional marginal.
- Each level/interval is sampled exactly once per factor.

LHD gives uniform one-dimensional marginals but may still cluster in higher dimensions, so maximin/minimax LHD improves spacing.

## 17. Causal Inference Introduction

### Potential outcomes

For unit \(i\) and binary treatment \(W_i\in\{0,1\}\):

- \(Y_i(1)\): potential outcome under treatment.
- \(Y_i(0)\): potential outcome under control.

Individual causal effect:

$$
\tau_i=Y_i(1)-Y_i(0).
$$

Only one potential outcome is observed:

$$
Y_i^{obs}=W_iY_i(1)+(1-W_i)Y_i(0).
$$

This is the fundamental problem of causal inference.

### Average treatment effects

Average treatment effect:

$$
ATE=E[Y_i(1)-Y_i(0)]
=E[Y_i(1)]-E[Y_i(0)].
$$

Sample average treatment effect:

$$
SATE=\frac{1}{N}\sum_{i=1}^N [Y_i(1)-Y_i(0)].
$$

Population average treatment effect:

$$
PATE=E_{\text{superpop}}[Y_i(1)-Y_i(0)].
$$

Average treatment effect on the treated:

$$
ATT=E[Y_i(1)-Y_i(0)\mid W_i=1].
$$

Average treatment effect on the untreated:

$$
ATU=E[Y_i(1)-Y_i(0)\mid W_i=0].
$$

### SUTVA

Stable Unit Treatment Value Assumption:

- No interference: one unit's potential outcomes do not depend on other units' treatments.
- No hidden versions of treatment: treatment levels are well-defined.

### Random assignment

If treatment assignment is randomized:

$$
(Y_i(0),Y_i(1))\perp W_i.
$$

Then the difference in observed group means is an unbiased estimator of ATE:

$$
\hat\tau=\bar Y_{\text{treat}}-\bar Y_{\text{control}}.
$$

Random assignment also implies, in expectation:

$$
ATT=ATE=ATU.
$$

Two main error sources:

- Random counterfactuals: missing potential outcomes due to assignment.
- Sampling variability: finite sample drawn from a superpopulation.

## 18. Degrees of Freedom Cheat Sheet

### Linear model

$$
df_E=n-p.
$$

### CRD one-way ANOVA

$$
df_E=N-a.
$$

### Paired comparison

$$
df_E=n_{\text{pairs}}-1.
$$

### RCBD

$$
df_E=(a-1)(b-1).
$$

### Latin square of order \(p\)

$$
df_E=(p-1)(p-2).
$$

### Two-factor factorial with \(a,b,n\)

$$
df_E=ab(n-1).
$$

### Full \(2^k\) with \(n\) replicates and all effects

$$
df_E=2^k(n-1).
$$

### Full \(3^2\) with \(n\) replicates and all effects

$$
df_E=9(n-1).
$$

### Unreplicated \(2^{k-p}\) fitted with selected model

$$
df_E=2^{k-p}-p_{\text{model}},
$$

where \(p_{\text{model}}\) includes the intercept and all included estimable terms.

### CCD with \(k\) factors

Total runs:

$$
N=n_F+2k+n_C.
$$

Standard second-order parameter count:

$$
p=1+2k+\binom{k}{2}.
$$

Residual df:

$$
df_E=N-p.
$$
