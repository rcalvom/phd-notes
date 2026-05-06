"""Reusable STAT 514 exam calculators.

The goal is not to replace thinking during the exam. It is to avoid arithmetic
errors in common DOE calculations: factorial effects, residual df, fractional
factorial aliasing, CCD run counts, curvature tests, and RSM stationary points.

This file only depends on numpy, which is already used by the other scripts.
Edit the example data in the `if __name__ == "__main__"` block as needed.
"""

from __future__ import annotations

import itertools
import math

import numpy as np


def full_factorial_df(k: int, replicates: int) -> int:
    """Residual df for a full 2^k factorial with all effects fitted."""
    return (2**k) * (replicates - 1)


def selected_model_df(total_runs: int, n_terms_excluding_intercept: int) -> int:
    """Residual df for a selected model."""
    return total_runs - (1 + n_terms_excluding_intercept)


def second_order_parameter_count(k: int) -> int:
    """Parameter count for a full second-order model in k factors."""
    return 1 + k + k + math.comb(k, 2)


def ccd_run_count(k: int, center_runs: int, factorial_runs: int | None = None) -> int:
    """Total runs in a CCD: factorial + 2k axial + center runs."""
    if factorial_runs is None:
        factorial_runs = 2**k
    return factorial_runs + 2 * k + center_runs


def rotatable_alpha(factorial_runs: int) -> float:
    """Rotatable CCD axial distance alpha = n_F^(1/4)."""
    return factorial_runs ** 0.25


def two_level_effects(design: np.ndarray, y: np.ndarray, factor_names: list[str]) -> dict[str, float]:
    """Compute all factorial effects for a balanced two-level design.

    `design` must contain only -1/+1 columns for the factorial runs. If the
    design is replicated, include each observation as a row. Center points should
    not be included here.

    Effect formula:
        effect_T = mean(y | sign_T = +1) - mean(y | sign_T = -1)
                 = 2 * sum(sign_T * y) / N
    """
    design = np.asarray(design, dtype=float)
    y = np.asarray(y, dtype=float)
    if design.shape[0] != y.shape[0]:
        raise ValueError("design and y must have the same number of rows")
    if design.shape[1] != len(factor_names):
        raise ValueError("factor_names length must match design columns")

    effects: dict[str, float] = {}
    n_runs = len(y)
    for order in range(1, len(factor_names) + 1):
        for idxs in itertools.combinations(range(len(factor_names)), order):
            name = "".join(factor_names[i] for i in idxs)
            signs = np.prod(design[:, idxs], axis=1)
            effects[name] = float(2 * np.dot(signs, y) / n_runs)
    return effects


def print_effects(effects: dict[str, float]) -> None:
    """Pretty-print effects and their regression coefficients."""
    print("Effect estimates; coded-regression beta = effect / 2")
    for name, effect in effects.items():
        print(f"{name:>8s}: effect={effect:9.4f}, beta={effect / 2:9.4f}")


def fit_least_squares(X: np.ndarray, y: np.ndarray, term_names: list[str] | None = None) -> dict[str, object]:
    """Fit y = X beta + error by least squares."""
    X = np.asarray(X, dtype=float)
    y = np.asarray(y, dtype=float)
    beta, _, rank, _ = np.linalg.lstsq(X, y, rcond=None)
    fitted = X @ beta
    residuals = y - fitted
    sse = float(np.dot(residuals, residuals))
    df_error = X.shape[0] - rank
    mse = sse / df_error if df_error > 0 else float("nan")

    if term_names is None:
        term_names = [f"b{i}" for i in range(X.shape[1])]

    print("Least-squares fit")
    for name, value in zip(term_names, beta):
        print(f"{name:>12s}: {value:10.5f}")
    print(f"rank={rank}, df_error={df_error}, SSE={sse:.5f}, MSE={mse:.5f}")

    return {
        "beta": beta,
        "fitted": fitted,
        "residuals": residuals,
        "sse": sse,
        "df_error": df_error,
        "mse": mse,
        "rank": rank,
    }


def second_order_design_matrix(points: np.ndarray) -> tuple[np.ndarray, list[str]]:
    """Build [1, linear terms, squared terms, pairwise interactions]."""
    points = np.asarray(points, dtype=float)
    n, k = points.shape
    cols = [np.ones(n)]
    names = ["Intercept"]

    for i in range(k):
        cols.append(points[:, i])
        names.append(f"x{i + 1}")
    for i in range(k):
        cols.append(points[:, i] ** 2)
        names.append(f"x{i + 1}^2")
    for i, j in itertools.combinations(range(k), 2):
        cols.append(points[:, i] * points[:, j])
        names.append(f"x{i + 1}x{j + 1}")

    return np.column_stack(cols), names


def fit_second_order(points: np.ndarray, y: np.ndarray) -> dict[str, object]:
    """Fit a standard second-order response-surface model."""
    X, names = second_order_design_matrix(points)
    return fit_least_squares(X, y, names)


def B_matrix(quadratic: list[float], interactions: dict[tuple[int, int], float] | None = None) -> np.ndarray:
    """Construct B for y = b0 + x'b + x'Bx.

    Diagonal entries are pure quadratic coefficients. Off-diagonal entries are
    half of the corresponding x_i x_j coefficient.
    Indices in `interactions` are zero-based, e.g. (0, 1): beta12.
    """
    k = len(quadratic)
    B = np.diag(np.asarray(quadratic, dtype=float))
    if interactions:
        for (i, j), coefficient in interactions.items():
            B[i, j] = coefficient / 2
            B[j, i] = coefficient / 2
    return B


def stationary_point(linear: list[float], B: np.ndarray, intercept: float = 0.0) -> dict[str, object]:
    """Find and classify the stationary point of a second-order model."""
    b = np.asarray(linear, dtype=float)
    B = np.asarray(B, dtype=float)
    xs = -0.5 * np.linalg.solve(B, b)
    yhat = float(intercept + np.dot(xs, b) + xs @ B @ xs)
    eigenvalues = np.linalg.eigvals(B)

    if np.all(eigenvalues < 0):
        surface = "maximum"
    elif np.all(eigenvalues > 0):
        surface = "minimum"
    else:
        surface = "saddle"

    print("Stationary point analysis")
    print(f"B =\n{B}")
    print(f"x_s = {xs}")
    print(f"yhat(x_s) = {yhat:.5f}")
    print(f"eigenvalues = {eigenvalues}")
    print(f"classification = {surface}")

    return {"x_s": xs, "yhat": yhat, "eigenvalues": eigenvalues, "classification": surface}


def curvature_test(factorial_y: list[float], center_y: list[float]) -> dict[str, float]:
    """Curvature test using factorial points and replicated center points."""
    factorial = np.asarray(factorial_y, dtype=float)
    center = np.asarray(center_y, dtype=float)
    nf = len(factorial)
    nc = len(center)
    if nc < 2:
        raise ValueError("At least two center points are needed for pure error")

    mean_f = float(np.mean(factorial))
    mean_c = float(np.mean(center))
    mse_pure = float(np.sum((center - mean_c) ** 2) / (nc - 1))
    ss_curvature = float((nf * nc / (nf + nc)) * (mean_f - mean_c) ** 2)
    f_value = ss_curvature / mse_pure
    t_value = (mean_c - mean_f) / math.sqrt(mse_pure * (1 / nc + 1 / nf))

    print("Curvature test")
    print(f"factorial mean={mean_f:.5f}, center mean={mean_c:.5f}")
    print(f"MSE pure error={mse_pure:.5f}, df={nc - 1}")
    print(f"SS_curvature={ss_curvature:.5f}, F={f_value:.5f}, t={t_value:.5f}")

    return {
        "factorial_mean": mean_f,
        "center_mean": mean_c,
        "mse_pure": mse_pure,
        "df_error": nc - 1,
        "ss_curvature": ss_curvature,
        "f": f_value,
        "t": t_value,
    }


def _parse_word(word: str) -> tuple[int, frozenset[str]]:
    word = word.strip().replace(" ", "")
    sign = -1 if word.startswith("-") else 1
    word = word.lstrip("+-")
    if word in {"", "I"}:
        return sign, frozenset()
    return sign, frozenset(word)


def _multiply_words(a: tuple[int, frozenset[str]], b: tuple[int, frozenset[str]]) -> tuple[int, frozenset[str]]:
    sign = a[0] * b[0]
    factors = a[1].symmetric_difference(b[1])
    return sign, frozenset(sorted(factors))


def _format_word(term: tuple[int, frozenset[str]]) -> str:
    sign, factors = term
    body = "".join(sorted(factors)) if factors else "I"
    return body if sign > 0 else f"-{body}"


def alias_set(effect: str, defining_relation: list[str]) -> list[str]:
    """Alias an effect by multiplying by every word in the defining relation.

    Example:
        alias_set("A", ["I", "ABCD", "-ACE", "-BDE"])
    """
    effect_term = _parse_word(effect)
    aliases = []
    for word in defining_relation:
        aliases.append(_format_word(_multiply_words(effect_term, _parse_word(word))))
    return aliases


def print_aliases(effects: list[str], defining_relation: list[str]) -> None:
    """Pretty-print alias sets for selected effects."""
    print(f"Defining relation: {' = '.join(defining_relation)}")
    for effect in effects:
        print(f"{effect:>6s}: {' = '.join(alias_set(effect, defining_relation))}")


if __name__ == "__main__":
    print("\n--- Degrees of freedom helpers ---")
    print(f"Full 2^4 with 3 reps df_E = {full_factorial_df(k=4, replicates=3)}")
    print(f"CCD k=3, 2^(3-1) factorial, 5 centers runs = {ccd_run_count(k=3, factorial_runs=2**2, center_runs=5)}")
    print(f"Second-order parameter count k=3 = {second_order_parameter_count(k=3)}")

    print("\n--- Practice Problem 5: 2^3 effects ---")
    design_23 = np.array([
        [-1, -1, -1],
        [1, -1, -1],
        [-1, 1, -1],
        [1, 1, -1],
        [-1, -1, 1],
        [1, -1, 1],
        [-1, 1, 1],
        [1, 1, 1],
    ])
    y_23 = np.array([98, 72, 87, 85, 99, 79, 87, 80])
    print_effects(two_level_effects(design_23, y_23, ["A", "B", "C"]))

    print("\n--- Practice Problem 6: aliases ---")
    defining = ["I", "ABCD", "-ACE", "-BDE"]
    print_aliases(["A", "B", "C", "D", "E", "AB"], defining)

    print("\n--- Practice Problem 7: curvature with center points ---")
    curvature_test(factorial_y=[54, 47, 32, 45], center_y=[40, 38, 42])

    print("\n--- Practice Problem 8: RSM stationary point ---")
    B = B_matrix(quadratic=[-2, -1])
    stationary_point(linear=[4, -2], B=B, intercept=8)
