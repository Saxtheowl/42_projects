import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "scripts"
sys.path.append(str(ROOT))

from validation_summary import parse_report, summarize  # type: ignore


def test_parse_report_with_bootstrap():
    report = "\n".join(
        [
            "fold 1: RMSE=1200.50, theta0=1.0, theta1=2.0, last_lr=0.01",
            "fold 2: RMSE=900.25, theta0=1.5, theta1=2.5, last_lr=0.01",
            "average RMSE across folds: 1050.38",
            "bootstrap 1: RMSE=800.10, oob=4, last_lr=0.01",
            "bootstrap 2: RMSE=950.20, oob=3, last_lr=0.01",
            "bootstrap average RMSE: 875.15",
        ]
    )
    folds, avg, bootstrap_rmses, bootstrap_avg = parse_report(report)
    assert len(folds) == 2
    assert avg == 1050.38
    assert bootstrap_rmses == [800.10, 950.20]
    assert bootstrap_avg == 875.15


def test_summarize_includes_bootstrap():
    report = "\n".join(
        [
            "fold 1: RMSE=1200.50, theta0=1.0, theta1=2.0, last_lr=0.01",
            "fold 2: RMSE=900.25, theta0=1.5, theta1=2.5, last_lr=0.01",
            "average RMSE across folds: 1050.38",
            "bootstrap 1: RMSE=800.10, oob=4, last_lr=0.01",
            "bootstrap 2: RMSE=950.20, oob=3, last_lr=0.01",
            "bootstrap average RMSE: 875.15",
        ]
    )
    folds, avg, bootstrap_rmses, bootstrap_avg = parse_report(report)
    summary = summarize(folds, avg, bootstrap_rmses, bootstrap_avg)
    assert "bootstrap samples: 2" in summary
    assert "bootstrap average RMSE: 875.15" in summary
