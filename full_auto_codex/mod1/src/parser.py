"""Parsing utilities for .mod1 terrain definition files."""

from __future__ import annotations

from pathlib import Path
from typing import List

from .utils import Point3D


def load_control_points(path: str | Path) -> List[Point3D]:
	"""Return the list of control points described in *path*.

	Each line is expected to contain three numbers separated by spaces or tabs.
	Empty lines and lines starting with ``#`` are ignored.
	"""
	points: List[Point3D] = []
	with Path(path).expanduser().open("r", encoding="utf-8") as handle:
		for index, raw_line in enumerate(handle, start=1):
			line = raw_line.strip()
			if not line or line.startswith("#"):
				continue
			parts = line.split()
			if len(parts) != 3:
				raise ValueError(
					f"invalid line {index} in {path}: expected 3 values, got {len(parts)}"
				)
			try:
				x, y, z = map(float, parts)
			except ValueError as exc:
				raise ValueError(
					f"invalid numeric value on line {index} in {path}"
				) from exc
			points.append((x, y, z))
	if not points:
		raise ValueError(f"{path} does not contain any control point")
	return points
