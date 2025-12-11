# Review outcome (2025-12-12)

- **Reviewer** : 42Net reviewer (session 12/12 15h00).
- **Validated actions** :
  1. Keep `--scheduler exponential` with `--decay 0.95` as the default; `--min-lr 1e-9` protects even when RMSE plateaus.
  2. Track per-epoch RMSE via `data/history.json` and surface the summary through `scripts/reports/rmse_plot.py` (PNG optional) and `scripts/validation.py` (fold averages) as evidence of convergence.
  3. Document new validation strategy (+ bootstrap idea) in `notes/review_followup.md` and update `C/ft_linear_regression/README.md` to highlight the recommended workflow.

- **Next steps** :
  - Implement the scheduler/validation pipeline inside `ft_linear_regression` (already done).
  - Use plots/validation summary to detect overfitting, adjust decay or split size if needed.
  - Close the review loop by posting this summary in `progress.md` of both `ft_helpme` and `ft_linear_regression`.
