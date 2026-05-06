# STAT 514 Practice Final Solutions

Source: `midterms/midterm3/practice.pdf`.

These solutions are written as exam notes. Each problem includes the reusable formulas first when useful, then the numbers for this practice exam.

## 1. Fill in the blank

### 1(a)

A \(2^{8-3}_{IV}\) design has

\[
2^{8-3}=2^5=32
\]

runs and \(8\) factors of 2 levels each.

### 1(b)

In a resolution IV design, a two-factor interaction is not aliased with a main effect, but it is possibly aliased with another two-factor interaction.

### 1(c)

A \(2^{9-5}_{III}\) design has

\[
2^{9-5}=16
\]

runs, so it can estimate

\[
16-1=15
\]

factorial effects besides the intercept.

For a \(2^{k-p}\) fractional factorial, each effect has \(2^p-1\) aliases besides itself. Here \(p=5\), so each main effect is aliased with

\[
2^5-1=31
\]

other factorial effects.

### 1(d)

The fundamental principles for factorial effects are sparsity, hierarchy, and heredity.

### 1(e)

A CCD using a \(2^{5-1}_V\) factorial portion and 3 center points has

\[
n_F+2k+n_C=2^{5-1}+2(5)+3=16+10+3=29
\]

runs.

### 1(f)

A \(3^2\) full factorial design has

\[
3^2=9
\]

runs and \(2\) factors.

### 1(g)

A Latin hypercube design with \(n\) runs in \(k\) factors has 1 point in each of the \(n\) equally sized intervals of every one-dimensional marginal, so that each level is sampled 1 time per factor.

### 1(h)

A maximin Latin hypercube design chooses design points to maximize the minimum of all pairwise distances, whereas a minimax design chooses points to minimize the maximum distance from any candidate input to its nearest design point.

## 2. Residual degrees of freedom

General rule:

\[
df_E=N-p,
\]

where \(p\) is the number of fitted model parameters including the intercept.

### 2(a)

CRD with 3 treatments and \(7,8,9\) replicates:

\[
N=7+8+9=24,\qquad p=3.
\]

\[
df_E=N-a=24-3=21.
\]

### 2(b)

Randomized paired comparison with 15 pairs:

\[
df_E=n_{\text{pairs}}-1=15-1=14.
\]

### 2(c)

Full \(2^4\) factorial with three replicates and all factorial effects:

\[
N=2^4(3)=48,\qquad p=2^4=16.
\]

\[
df_E=48-16=32.
\]

Equivalently,

\[
df_E=2^k(n-1)=2^4(3-1)=32.
\]

### 2(d)

Unreplicated \(2^{8-2}\) design:

\[
N=2^6=64.
\]

Model includes the intercept, 8 main effects, and \(\binom{8}{2}=28\) two-factor interactions:

\[
p=1+8+28=37.
\]

\[
df_E=64-37=27.
\]

### 2(e)

CCD using a \(2^{3-1}\) factorial portion and 5 center runs:

\[
N=2^{3-1}+2(3)+5=4+6+5=15.
\]

A standard second-order model with \(k=3\) factors has

\[
p=1+k+k+\binom{k}{2}=1+3+3+3=10.
\]

\[
df_E=15-10=5.
\]

### 2(f)

Full \(3^2\) factorial with two replicates:

\[
N=3^2(2)=18.
\]

The full \(3^2\) model has \(p=9\) cell means or \(1+2+2+4=9\) parameters.

\[
df_E=18-9=9.
\]

## 3. Choose the design

### 3(a)

Use a 16-run \(2^{7-3}\) fractional factorial design, preferably maximum resolution IV.

Reasoning: there are seven two-level factors, the run limit is 16, and the goal is screening. A resolution IV design keeps main effects clear of two-factor interactions, although two-factor interactions may be aliased with each other.

Blocking factor: none stated.

Sample size:

\[
N=16.
\]

### 3(b)

Use a central composite design (CCD) for the three quantitative factors.

Reasoning: the engineer expects curvature and interactions, and wants to fit a second-order model for prediction and optimization.

Blocking factor: none stated.

General sample size:

\[
N=2^3+2(3)+n_C=14+n_C.
\]

With 5 center runs, a common choice:

\[
N=8+6+5=19.
\]

### 3(c)

Use a space-filling design, specifically a maximin Latin hypercube design with \(n=100\) runs and \(k=12\) factors.

Reasoning: the simulator is deterministic, replication is wasteful, and the goal is broad exploration plus emulator construction. An LHD samples each one-dimensional marginal level once.

Blocking factor: none.

Sample size:

\[
N=100.
\]

### 3(d)

Use a completely randomized design (CRD).

Reasoning: the aquaria are homogeneous and there are no clear nuisance factors to block on.

Blocking factor: none.

Sample size:

\[
N=40,
\]

balanced as 10 aquaria per diet.

### 3(e)

Use a randomized complete block design (RCBD), blocking on production day.

Reasoning: day-to-day variation is known and important, and each day can contain all three hardening treatment levels.

Blocking factor: production day.

Sample size:

\[
N=3(5)=15.
\]

## 4. Two-factor \(3\times 3\) factorial ANOVA

### 4(a)

Let \(i=1,2,3\) index cutting speed, \(j=1,2,3\) index coolant type, and \(k=1,\ldots,4\) index replicates.

The two-factor ANOVA model with interaction is

\[
y_{ijk}=\mu+\alpha_i+\beta_j+(\alpha\beta)_{ij}+\varepsilon_{ijk},
\]

with

\[
\varepsilon_{ijk}\stackrel{iid}{\sim}N(0,\sigma^2).
\]

Zero-sum constraints:

\[
\sum_{i=1}^3\alpha_i=0,\qquad
\sum_{j=1}^3\beta_j=0,
\]

\[
\sum_{i=1}^3(\alpha\beta)_{ij}=0\quad\text{for each }j,
\qquad
\sum_{j=1}^3(\alpha\beta)_{ij}=0\quad\text{for each }i.
\]

### 4(b)

There are \(3\times 3\times 4=36\) observations.

Degrees of freedom:

\[
df_A=2,\quad df_B=2,\quad df_{AB}=4,\quad df_E=3\cdot 3(4-1)=27,\quad df_T=35.
\]

Since \(R^2=0.94\),

\[
R^2=1-\frac{SSE}{SST}.
\]

Given \(SSE=18\):

\[
0.94=1-\frac{18}{SST}
\quad\Longrightarrow\quad
SST=\frac{18}{0.06}=300.
\]

Then

\[
MSE=\frac{18}{27}=\frac{2}{3}.
\]

Cutting speed has \(F=90\), so

\[
MS_A=90MSE=90\left(\frac{2}{3}\right)=60,\qquad
SS_A=2(60)=120.
\]

Coolant type has \(SS_B=90\), so

\[
MS_B=\frac{90}{2}=45,\qquad
F_B=\frac{45}{2/3}=67.5.
\]

Interaction:

\[
SS_{AB}=SST-SS_A-SS_B-SSE=300-120-90-18=72.
\]

\[
MS_{AB}=\frac{72}{4}=18,\qquad
F_{AB}=\frac{18}{2/3}=27.
\]

Completed table:

| Source | df | SS | MS | F |
|---|---:|---:|---:|---:|
| Cutting speed | 2 | 120 | 60 | 90 |
| Coolant type | 2 | 90 | 45 | 67.5 |
| Interaction | 4 | 72 | 18 | 27 |
| Error | 27 | 18 | \(2/3\) |  |
| Total | 35 | 300 |  |  |

## 5. Single-replicate \(2^3\) design

The reusable effect formula in a \(2^k\) design is

\[
\widehat{\text{effect}}_T
=\bar y_{T+}-\bar y_{T-}
=\frac{1}{2^{k-1}}\sum_{\text{runs}}s_Ty,
\]

for one replicate, where \(s_T\) is the product of coded signs for term \(T\).

### 5(a)

Main effect of \(A\):

\[
\bar y_{A+}=\frac{72+85+79+80}{4}=79,
\]

\[
\bar y_{A-}=\frac{98+87+99+87}{4}=92.75.
\]

\[
\hat A=\bar y_{A+}-\bar y_{A-}=79-92.75=-13.75.
\]

### 5(b)

For \(AB\), the sign is \(x_Ax_B\).

\[
\bar y_{AB+}=\frac{98+85+99+80}{4}=90.5,
\]

\[
\bar y_{AB-}=\frac{72+87+79+87}{4}=81.25.
\]

\[
\widehat{AB}=90.5-81.25=9.25.
\]

### 5(c)

Main effect plot for \(A\):

| \(A\) level | Mean response |
|---:|---:|
| \(-1\) | 92.75 |
| \(+1\) | 79.00 |

The line decreases from \(A=-1\) to \(A=+1\), so high \(A\) lowers roughness.

AB interaction plot values:

| \(B\) level | Mean at \(A=-1\) | Mean at \(A=+1\) |
|---:|---:|---:|
| \(-1\) | \((98+99)/2=98.5\) | \((72+79)/2=75.5\) |
| \(+1\) | \((87+87)/2=87.0\) | \((85+80)/2=82.5\) |

The lines are not parallel. The effect of \(A\) is much stronger when \(B=-1\).

### 5(d)

Reduced model:

\[
y=\beta_0+\beta_Ax_A+\beta_{AB}x_Ax_B+\varepsilon.
\]

In an orthogonal two-level factorial design:

\[
\hat\beta_0=\bar y,\qquad
\hat\beta_T=\frac{\widehat{\text{effect}}_T}{2}.
\]

Grand mean:

\[
\hat\beta_0=\bar y=\frac{98+72+87+85+99+79+87+80}{8}=85.875.
\]

\[
\hat\beta_A=\frac{-13.75}{2}=-6.875.
\]

\[
\hat\beta_{AB}=\frac{9.25}{2}=4.625.
\]

Fitted model:

\[
\hat y=85.875-6.875x_A+4.625x_Ax_B.
\]

### 5(e)

Predictions:

| \(A\) | \(B\) | \(x_Ax_B\) | \(\hat y\) |
|---:|---:|---:|---:|
| \(-1\) | \(-1\) | \(+1\) | \(85.875+6.875+4.625=97.375\) |
| \(+1\) | \(-1\) | \(-1\) | \(85.875-6.875-4.625=74.375\) |
| \(-1\) | \(+1\) | \(-1\) | \(85.875+6.875-4.625=88.125\) |
| \(+1\) | \(+1\) | \(+1\) | \(85.875-6.875+4.625=83.625\) |

Minimum predicted roughness occurs at

\[
A=+1,\qquad B=-1,
\]

with predicted roughness

\[
\hat y=74.375.
\]

## 6. Fractional factorial design

The columns are generated from the basic factors \(A,B,C\).

### 6(a)

Compare \(D\) with products of \(A,B,C\). The column \(D\) equals \(ABC\), so the generator is

\[
D=ABC.
\]

Equivalently,

\[
I=ABCD.
\]

### 6(b)

The column \(E\) equals \(-AC\), so the generator is

\[
E=-AC.
\]

Equivalently,

\[
I=-ACE.
\]

### 6(c)

The two independent defining words are

\[
I=ABCD,\qquad I=-ACE.
\]

Multiply them to get the third nonidentity word:

\[
(ABCD)(-ACE)=-BDE.
\]

Complete defining relation:

\[
I=ABCD=-ACE=-BDE.
\]

### 6(d)

Resolution is the length of the shortest word in the defining relation, ignoring the sign.

The words are \(ABCD\) of length 4, \(ACE\) of length 3, and \(BDE\) of length 3. Therefore the design has resolution

\[
III.
\]

### 6(e)

Reverse the signs of column \(B\). If the new column is still called \(B\), then the old \(B\) is \(-B\).

The old relation \(D=A B_{\text{old}} C\) becomes

\[
D=-ABC,
\]

so

\[
I=-ABCD.
\]

The relation for \(E\) is unchanged:

\[
E=-AC,\qquad I=-ACE.
\]

Multiplying the two words:

\[
(-ABCD)(-ACE)=BDE.
\]

Complete defining relation for the second fraction:

\[
I=-ABCD=-ACE=BDE.
\]

## 7. \(2^2\) factorial with center points

The four factorial points estimate factorial effects. The center points estimate pure error and curvature.

### 7(a)

\[
\bar y_{A+}=\frac{32+45}{2}=38.5,
\qquad
\bar y_{A-}=\frac{54+47}{2}=50.5.
\]

\[
\hat A=38.5-50.5=-12.
\]

### 7(b)

\[
\bar y_{AB+}=\frac{54+45}{2}=49.5,
\qquad
\bar y_{AB-}=\frac{47+32}{2}=39.5.
\]

\[
\widehat{AB}=49.5-39.5=10.
\]

### 7(c)

Use center points \(40,38,42\) to estimate pure error:

\[
\bar y_C=\frac{40+38+42}{3}=40.
\]

\[
\hat\sigma^2=MSE_{\text{pure error}}
=\frac{(40-40)^2+(38-40)^2+(42-40)^2}{3-1}
=\frac{8}{2}=4.
\]

Degrees of freedom:

\[
df_E=n_C-1=3-1=2.
\]

### 7(d)

For a \(2^2\) factorial with one replicate, the standard error of an effect is

\[
SE(\widehat{\text{effect}})=\sqrt{MSE}.
\]

Thus

\[
SE(\widehat{AB})=\sqrt{4}=2.
\]

Test statistic:

\[
t_0=\frac{\widehat{AB}}{SE(\widehat{AB})}=\frac{10}{2}=5.
\]

For a two-sided 5% test with \(df=2\):

\[
t_{0.025,2}=4.303.
\]

Since

\[
|5|>4.303,
\]

the \(AB\) interaction is significant at the 5% level.

### 7(e)

Curvature compares the average at center points with the average at factorial points.

\[
\bar y_F=\frac{54+47+32+45}{4}=44.5,
\qquad
\bar y_C=40.
\]

Curvature contrast:

\[
\hat C=\bar y_C-\bar y_F=40-44.5=-4.5.
\]

Standard error:

\[
SE(\hat C)=\sqrt{MSE\left(\frac{1}{n_C}+\frac{1}{n_F}\right)}
=\sqrt{4\left(\frac{1}{3}+\frac{1}{4}\right)}
=\sqrt{\frac{7}{3}}
=1.528.
\]

Test statistic:

\[
t_0=\frac{-4.5}{1.528}=-2.95.
\]

For a two-sided 5% test with \(df=2\):

\[
t_{0.025,2}=4.303.
\]

Since

\[
|-2.95|<4.303,
\]

the curvature effect is not significant at the 5% level.

Equivalent F-test:

\[
SS_{\text{curv}}=
\frac{n_Fn_C}{n_F+n_C}(\bar y_F-\bar y_C)^2
=\frac{4\cdot 3}{7}(44.5-40)^2=34.714.
\]

\[
F_{\text{curv}}=\frac{34.714}{4}=8.679
\]

with \(1\) and \(2\) degrees of freedom. Since \(F=t^2\), this is the same conclusion.

## 8. Central composite design and stationary point

The fitted model is

\[
y=8+4x_1-2x_2-2x_1^2-x_2^2+\varepsilon.
\]

### 8(a)

For a circumscribed CCD with \(k=2\), \(\alpha=\sqrt 2\), and 3 center points.

Factorial points:

\[
(-1,-1),\ (1,-1),\ (-1,1),\ (1,1).
\]

Axial points:

\[
(\sqrt2,0),\ (-\sqrt2,0),\ (0,\sqrt2),\ (0,-\sqrt2).
\]

Center points:

\[
(0,0),\ (0,0),\ (0,0).
\]

Total:

\[
N=4+4+3=11.
\]

### 8(b)

Matrix form:

\[
y=\beta_0+x'b+x'Bx+\varepsilon,
\qquad x=(x_1,x_2)'.
\]

Here

\[
\beta_0=8,\qquad
b=
\begin{pmatrix}
4\\
-2
\end{pmatrix}.
\]

There is no interaction term. Because \(x'Bx=B_{11}x_1^2+2B_{12}x_1x_2+B_{22}x_2^2\),

\[
B=
\begin{pmatrix}
-2 & 0\\
0 & -1
\end{pmatrix}.
\]

### 8(c)

Stationary point solves

\[
b+2Bx_s=0.
\]

Thus

\[
x_s=-\frac{1}{2}B^{-1}b.
\]

Since

\[
B^{-1}=
\begin{pmatrix}
-1/2 & 0\\
0 & -1
\end{pmatrix},
\]

\[
B^{-1}b=
\begin{pmatrix}
-2\\
2
\end{pmatrix}.
\]

Therefore

\[
x_s=-\frac12
\begin{pmatrix}
-2\\
2
\end{pmatrix}
=
\begin{pmatrix}
1\\
-1
\end{pmatrix}.
\]

The stationary point is

\[
(x_1,x_2)=(1,-1).
\]

### 8(d)

The eigenvalues of diagonal matrix \(B\) are its diagonal entries:

\[
\lambda_1=-2,\qquad \lambda_2=-1.
\]

Both eigenvalues are negative, so \(B\) is negative definite and the stationary point is a maximum.

The predicted maximum response is

\[
\hat y(1,-1)=8+4(1)-2(-1)-2(1)^2-(-1)^2=11.
\]
