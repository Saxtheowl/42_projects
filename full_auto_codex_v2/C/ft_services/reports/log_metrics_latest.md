# Latest Metrics Summary

- Suffix: `status_top2`

## Totals

| metric | value |
| --- | ---: |
| status_checks | 2 |
| connections | 1 |
| overloaded | 1 |
| overloaded_ratio | 50.00 |

## Deltas vs précédent

| metric | delta |
| --- | ---: |
| status_checks | +0.00 |
| connections | +0.00 |
| overloaded | +0.00 |
| overloaded_ratio | +0.00 |

## Anomalies

| metric | status | prev | curr | delta_pct |
| --- | --- | ---: | ---: | ---: |
| status_checks | OK |  |  |  |
| connections | OK |  |  |  |
| overloaded | OK |  |  |  |
| overloaded_ratio | OK |  |  |  |

## Badge
- Label : **uptime**
- État : **alert** (warn ≥ 30.0, alert ≥ 60.0, précédent: alert)
- Fenêtre historique: 20 (delta 10) — Comptage: {'ok': 0, 'fail': 0, 'unknown': 20, 'total': 20, 'window': 20, 'ok_pct': 0.0, 'fail_pct': 0.0, 'unknown_pct': 100.0} — Streak actuelle: 20 × alert
- Synthèse gardes (ok/fail/unknown/total/window/%) :
  - gate: ok=0 (0.0%), fail=0 (0.0%), unknown=20 (100.0%), total=20, window=20
  - ok_streak: ok=0 (0.0%), fail=0 (0.0%), unknown=20 (100.0%), total=20, window=20
  - no_regression: ok=0 (0.0%), fail=0 (0.0%), unknown=20 (100.0%), total=20, window=20

| guard | ok | fail | unknown | total | window | ok% | fail% | unknown% |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gate | 0 | 0 | 20 | 20 | 20 | 0.0% | 0.0% | 100.0% |
| ok_streak | 0 | 0 | 20 | 20 | 20 | 0.0% | 0.0% | 100.0% |
| no_regression | 0 | 0 | 20 | 20 | 20 | 0.0% | 0.0% | 100.0% |

### Streaks des gardes
| guard | current_result | current_len | longest_ok | longest_fail | longest_unknown | window |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| gate | unknown | 20 | 0 | 0 | 20 | 20 |
| ok_streak | unknown | 20 | 0 | 0 | 20 | 20 |
| no_regression | unknown | 20 | 0 | 0 | 20 | 20 |

### Synthèse globale des gardes
- Total fenêtre 20 : ok=0 (0.0%), fail=0 (0.0%), unknown=60 (100.0%), total=60

### Évolution vs fenêtre précédente
| guard | Δok | Δok% | Δfail | Δfail% | Δunknown | Δunknown% | window | delta_window |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| gate | +0 | 0.0% | +0 | 0.0% | +10 | 100.0% | 20 | 10 |
| ok_streak | +0 | 0.0% | +0 | 0.0% | +10 | 100.0% | 20 | 10 |
| no_regression | +0 | 0.0% | +0 | 0.0% | +10 | 100.0% | 20 | 10 |

### Synthèse globale des deltas
- Fenêtre 20 vs 10 précédents: ok=0 (0.0%), fail=0 (0.0%), unknown=30 (100.0%), total=30

## Artefacts

- CSV: [log_metrics_snapshot.status_top2.csv](log_metrics_snapshot.status_top2.csv)
- JSON: [log_metrics_snapshot.status_top2.json](log_metrics_snapshot.status_top2.json)
- JSONL: [log_metrics_snapshot.status_top2.jsonl](log_metrics_snapshot.status_top2.jsonl)
- Markdown: [log_metrics_snapshot.status_top2.md](log_metrics_snapshot.status_top2.md)
- HTML: [log_metrics_snapshot.status_top2.html](log_metrics_snapshot.status_top2.html)
- Summary (md): [log_metrics_snapshot.status_top2.summary.md](log_metrics_snapshot.status_top2.summary.md)
- Summary (html): [log_metrics_snapshot.status_top2.summary.html](log_metrics_snapshot.status_top2.summary.html)
- History: [log_metrics_history.csv](log_metrics_history.csv)
- Trend (md): [log_metrics_trend.md](log_metrics_trend.md)
- Trend (html): [log_metrics_trend.html](log_metrics_trend.html)
- Stats (md): [log_metrics_stats.md](log_metrics_stats.md)
- Stats (html): [log_metrics_stats.html](log_metrics_stats.html)
- Anomalies (md): [log_metrics_anomalies.md](log_metrics_anomalies.md)
- Anomalies (html): [log_metrics_anomalies.html](log_metrics_anomalies.html)
- Anomalies (json): [log_metrics_anomalies.json](log_metrics_anomalies.json)
- Overview (md): [log_metrics_overview.md](log_metrics_overview.md)
- Overview (html): [log_metrics_overview.html](log_metrics_overview.html)
- Latest (html): [log_metrics_latest.html](log_metrics_latest.html)
- Manifest: [log_metrics_manifest.json](log_metrics_manifest.json)
- Bundle: [log_metrics_bundle.tar.gz](log_metrics_bundle.tar.gz)
- Checksums: [log_metrics_checksums.txt](log_metrics_checksums.txt)
- Portal: [portal.html](portal.html)
- Index (md): [index.md](index.md)
- Index (html): [index.html](index.html)
- Badge (svg): [log_metrics_badge.svg](log_metrics_badge.svg)
- Guard summary (md): [log_metrics_guard_summary.md](log_metrics_guard_summary.md)
- Guard summary (html): [log_metrics_guard_summary.html](log_metrics_guard_summary.html)
- Guard summary (json): [log_metrics_guard_summary.json](log_metrics_guard_summary.json)
- Guard summary (csv): [log_metrics_guard_summary.csv](log_metrics_guard_summary.csv)