"""High-level scenarios producing sequences of frames."""

from __future__ import annotations

import math
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Iterator, List

from .renderer import render_frame
from .terrain import Terrain
from .water import (
	WaterField,
	add_rainfall,
	apply_wave,
	create_water_field,
	fill_uniform,
	flow_step,
	total_volume,
)
from .utils import allocate_grid, copy_grid


@dataclass
class ScenarioResult:
	"""Metadata associated with a simulation sequence."""

	name: str
	frame_paths: List[Path]


def _clone_field(field: WaterField) -> WaterField:
	return WaterField(copy_grid(field.depth))


def run_uniform_rise(
	terrain: Terrain,
	output_dir: Path,
	total_frames: int = 60,
	target_ratio: float = 0.75,
) -> ScenarioResult:
	"""Produce frames showing a uniform water level increase."""
	frame_paths: List[Path] = []
	target_height = terrain.min_height + terrain.height_range * target_ratio
	water = create_water_field(terrain)

	for frame_id in range(total_frames):
		level = terrain.min_height + (target_height - terrain.min_height) * (
			(frame_id + 1) / total_frames
		)
		fill_uniform(terrain, water.depth, level)
		path = output_dir / "uniform" / f"uniform_{frame_id:03d}.ppm"
		render_frame(terrain, water, path)
		frame_paths.append(path)

	return ScenarioResult(name="uniform", frame_paths=frame_paths)


def run_wave(
	terrain: Terrain,
	output_dir: Path,
	total_frames: int = 60,
	amplitude_ratio: float = 0.6,
	wave_width_ratio: float = 0.15,
	speed_ratio: float = 1.4,
) -> ScenarioResult:
	"""Visualise a wave travelling across the terrain."""
	frame_paths: List[Path] = []
	water = create_water_field(terrain)

	world_width = terrain.x_coords[-1] - terrain.x_coords[0]
	amplitude = max(terrain.height_range, 1.0) * amplitude_ratio
	wave_width = max(world_width * wave_width_ratio, 0.1)
	speed = world_width / total_frames * speed_ratio
	front = terrain.x_coords[0] - world_width * 0.3

	for frame_id in range(total_frames):
		current_front = front + speed * frame_id
		apply_wave(
			terrain,
			water.depth,
			front=current_front,
			amplitude=terrain.min_height + amplitude,
			width=wave_width,
		)
		path = output_dir / "wave" / f"wave_{frame_id:03d}.ppm"
		render_frame(terrain, water, path)
		frame_paths.append(path)

	return ScenarioResult(name="wave", frame_paths=frame_paths)


def _rain_positions(width: int, height: int, drops: int, rng: random.Random):
	for _ in range(drops):
		yield (rng.randrange(width), rng.randrange(height))


def run_rain(
	terrain: Terrain,
	output_dir: Path,
	total_frames: int = 60,
	drops_per_frame: int = 400,
	rain_amount: float = 0.08,
	flow_iterations: int = 2,
	seed: int = 42,
) -> ScenarioResult:
	"""Simulate rain accumulation with lateral water flow."""
	frame_paths: List[Path] = []
	water = create_water_field(terrain)
	rng = random.Random(seed)

	for frame_id in range(total_frames):
		positions = list(
			_rain_positions(terrain.width, terrain.height, drops_per_frame, rng)
		)
		add_rainfall(water.depth, positions, rain_amount)
		for _ in range(flow_iterations):
			flow_step(terrain, water.depth, rate=0.4, minimum_drop=0.02)
		path = output_dir / "rain" / f"rain_{frame_id:03d}.ppm"
		render_frame(terrain, water, path)
		frame_paths.append(path)

	return ScenarioResult(name="rain", frame_paths=frame_paths)


def run_all(
	terrain: Terrain,
	output_dir: Path,
	frames: int,
) -> List[ScenarioResult]:
	"""Convenience helper to render the three reference scenarios."""
	results = [
		run_uniform_rise(terrain, output_dir, total_frames=frames),
		run_wave(terrain, output_dir, total_frames=frames),
		run_rain(terrain, output_dir, total_frames=frames),
	]
	return results
