# Midterm 2 Practice - Quick Summary

## Problem 1: Identify the design

- **(a)** `Latin Square Design (LSD)` with $p=4$:
  - Treatment: teaching method (4 levels)
  - Nuisance/blocking factors: teacher and class period
  - Sample size: $N=p^2=16$
- **(b)** `Full $2^3$ factorial`, unreplicated:
  - 3 factors, 2 levels each
  - One run per treatment combination
  - Sample size: $N=2^3=8$
- **(c)** `Full $3^3$ factorial` with 4 replicates:
  - Sample size: $N=3^3\cdot 4=108$

---

## Problem 2: Can we estimate main effects, interactions, pure error?

- **(a) Unreplicated $2^3$**: main effects = Yes, interactions = Yes, pure error = No
- **(b) $2^2$ with 3 replicates**: main effects = Yes, interactions = Yes, pure error = Yes
- **(c) Latin square (5 treatments)**: main effects (treatment/rows/columns) = Yes, interactions = No (classical LSD model), pure error = No
- **(d) BIBD ($v=6,\ k=3$)**: treatment/block main effects = Yes, interactions = No (additive model), pure error = No

---

## Problem 3: Degrees of freedom

### (a) RCBD, 6 treatments, 5 blocks
- $N=30$, total $df=29$
- Treatments: $6-1=5$
- Blocks: $5-1=4$
- Error: $(6-1)(5-1)=20$

### (b) Latin square, $p=4$
- $N=16$, total $df=15$
- Treatments: $3$, Rows: $3$, Columns: $3$, Error: $(p-1)(p-2)=6$

### (c) $2^2$ factorial with 4 replicates
- $N=16$, total $df=15$
- $df_A=1,\ df_B=1,\ df_{AB}=1,\ df_E=2^2(4-1)=12$

### (d) Unreplicated $2^3$
- $N=8$, total $df=7$
- Main effects: $3$, two-factor interactions: $3$, three-factor interaction: $1$, error: $0$

### (e) $3^2$ factorial with 2 replicates
- $N=18$, total $df=17$
- $df_A=2,\ df_B=2,\ df_{AB}=4,\ df_E=9$

---

## Problem 4: Statistical models

- **(a) RCBD**
  
$$
y_{ij}=\mu+\tau_i+\beta_j+\varepsilon_{ij}
$$

- **(b) Latin square**
  
$$
y_{ijk}=\mu+\tau_i+\rho_j+\kappa_k+\varepsilon_{ijk}
$$

- **(c) Full $2^2$ factorial**
  
$$
y_{ijk}=\mu+\alpha_i+\beta_j+(\alpha\beta)_{ij}+\varepsilon_{ijk}
$$

- **(d) Full $2^3$ factorial (includes 3-way interaction)**
  
$$
y=\mu+\alpha+\beta+\gamma+\alpha\beta+\alpha\gamma+\beta\gamma+\alpha\beta\gamma+\varepsilon
$$

- **(e) BIBD**
  
$$
y_{ij}=\mu+\tau_i+\beta_j+\varepsilon_{ij}
$$


---

## Problem 5: ANOVA interpretation

Given table values: $F_A=20,\ F_B=1,\ F_{AB}=9,\ df_E=8$.

- **(a)** Important effects: **A** and **AB** (at 5%)
- **(b)** Evidence of interaction: **Yes**, because $F_{AB}=9 > F_{0.05;1,8}\approx 5.32$
- **(c)** Should A be interpreted alone? **No**, because AB is significant

---

## Problem 6: Active effects and pooling

Effects: $A=11.8,\ B=0.7,\ C=-0.5,\ AB=4.9,\ AC=0.5,\ BC=-0.6,\ ABC=0.4$

- Clearly active: **A**
- Likely active: **AB**
- Good candidates to pool as error: **ABC**, and typically also small effects ($B,\ C,\ AC,\ BC$)

---

## Problem 7: Suggested pooling and test

Data:

$$
A=9.0,\ B=1.0,\ C=0.5,\ AB=5.0,\ AC=0.6,\ BC=0.4,\ ABC=0.3
$$

Given:

$$
SS_{\text{effect}}=2(\text{effect})^2
$$


Using pooled error set $\{AC,\ C,\ BC,\ ABC\}$:
- $SS_{AC}=0.72,\ SS_C=0.50,\ SS_{BC}=0.32,\ SS_{ABC}=0.18$
- $SS_E=1.72,\ df_E=4,\ MSE=1.72/4=0.43$

Tests (kept effects $A,\ AB,\ B$):
- $F_A=162/0.43\approx 376.7$
- $F_{AB}=50/0.43\approx 116.3$
- $F_B=2/0.43\approx 4.65$

With $F_{0.95;1,4}=7.71$:
- Significant: **A, AB**
- Not significant: **B**

For (e): different pooling choices change $MSE$, so $F$-values and conclusions can change.

---

## Quick clarifications

- **Effect vs contrast**
  - Contrast: $\sum c_i\mu_i,\ \sum c_i=0$
  - Effect in factorials: a specific contrast (high vs low, etc.), often scaled
- **In factorial df notation**
  - $a_i$: number of levels of factor $i$
  - $s$: common number of levels when all factors have same levels ($s^k$ design)
- **In BIBD**
  - $v$: number of treatments
  - $k$: block size

