# mbSPLS — distribution & documentation

This repository is the **distribution** of the multiblock sparse PLS (MB-sPLS) toolbox: the
documentation website, a data-input template, compiled standalone executables, and the post-hoc
results scripts.

> ### ⚠ The compiled binaries in `2_Analysis/` are out of date
> They predate the correctness fixes applied to the source on **2026-09-26** — most importantly a
> convergence bug that could stop the solver after two iterations with the weights still moving,
> and a reported association statistic (`RHO`) that included the unit diagonal of the correlation
> matrix and so had a floor of `sqrt(n_blocks)` instead of 0.
>
> See `CHANGELOG_fixes.md` in the source repository for the full list and the numerical evidence.
> **Do not use `2_Analysis/` for new analyses until it has been rebuilt.**

## Where the source is

The algorithm source is **not in this repository** — it lives in the companion repository
`multiblock_spls`, under `scripts/MBSPLS_Toolbox/`. The core solver is `cv_mbspls.m`.

To rebuild the executables, run `cv_mbspls_compilation_script.m` from that repository; it compiles
the four modules (main, hyperparameter optimisation, permutation, bootstrap) and can copy the
result into `2_Analysis/` here.

## Layout

| Path | Contents |
|---|---|
| `1_Setup/` | `mb_spls_template_datafile.mat` — template for the `input`/`setup` structure |
| `2_Analysis/` | Compiled MATLAB Runtime executables (see the warning above) |
| `3_Results/` | Post-hoc reporting: tables, figures, PDF report, bootstrap pruning, latent scores |
| `docs/` | Jupyter-Book documentation source (published via `gh-pages`) |

## Usage

1. Build a `datafile.mat` following [`docs/mbspls_1setup.md`](docs/mbspls_1setup.md).
2. Submit it to the compiled toolbox as described in [`docs/mbspls_2run.md`](docs/mbspls_2run.md).
3. Generate the report with `3_Results/mb_spls_results_main.m`.

## Related repositories

- **`multiblock_spls`** — the MATLAB source this distribution is compiled from.
- **`mlr3mbspls`** — an independent R/Rcpp implementation of MB-sPLS as `mlr3pipelines` operators.
  Since the 2026-09-26 fixes its Frobenius objective is numerically identical to this toolbox's
  `RHO`, so results from the two are directly comparable.

## Note on `3_Results/`

These scripts have diverged from their counterparts in `multiblock_spls`
(`scripts/MBSPLS_Toolbox/mb_spls_results_mean_*.m`) — roughly 200 differing lines. Consider
consolidating on one copy to avoid the two drifting further apart.
