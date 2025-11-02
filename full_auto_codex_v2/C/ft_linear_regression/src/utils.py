from __future__ import annotations

import csv
import json
from dataclasses import dataclass
from pathlib import Path
from typing import List

THETA_FILE = Path(__file__).resolve().parent.parent / "data" / "theta.json"


@dataclass
class Dataset:
    mileage: List[float]
    price: List[float]


@dataclass
class ModelParams:
    theta0: float
    theta1: float
    mean: float
    scale: float


def load_dataset(path: Path) -> Dataset:
    mileage: List[float] = []
    price: List[float] = []
    with path.open("r", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            mileage.append(float(row["mileage"]))
            price.append(float(row["price"]))
    return Dataset(mileage=mileage, price=price)


def save_model(params: ModelParams) -> None:
    THETA_FILE.parent.mkdir(parents=True, exist_ok=True)
    with THETA_FILE.open("w", encoding="utf-8") as fh:
        json.dump({
            "theta0": params.theta0,
            "theta1": params.theta1,
            "mean": params.mean,
            "scale": params.scale,
        }, fh)


def load_model() -> ModelParams:
    if THETA_FILE.exists():
        with THETA_FILE.open("r", encoding="utf-8") as fh:
            data = json.load(fh)
        return ModelParams(
            theta0=float(data.get("theta0", 0.0)),
            theta1=float(data.get("theta1", 0.0)),
            mean=float(data.get("mean", 0.0)),
            scale=float(data.get("scale", 1.0)),
        )
    return ModelParams(theta0=0.0, theta1=0.0, mean=0.0, scale=1.0)
