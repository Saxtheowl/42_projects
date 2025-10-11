"""Command-line entry-point for the mod1 terrain & water simulator."""

from __future__ import annotations

import argparse
from pathlib import Path

from .parser import load_control_points
from .scenarios import (
	run_all,
	run_rain,
	run_uniform_rise,
	run_wave,
)
from .terrain import generate_terrain


def _build_argument_parser() -> argparse.ArgumentParser:
	parser = argparse.ArgumentParser(
		description="Water flow simulator inspired by the 42 mod1 project.",
	)
	parser.add_argument("mod1_file", help="Path to the .mod1 control points file.")
	parser.add_argument(
		"--resolution",
		type=int,
		default=64,
		help="Number of samples used per axis when interpolating the terrain (default: 64).",
	)
	parser.add_argument(
		"--scenario",
		choices=["uniform", "wave", "rain", "all"],
		default="all",
		help="Which scenario to render (default: all).",
	)
	parser.add_argument(
		"--frames",
		type=int,
		default=60,
		help="Number of frames produced for the requested scenario (default: 60).",
	)
	parser.add_argument(
		"--output",
		type=Path,
		default=Path("outputs"),
		help="Directory where frames will be generated (default: ./outputs).",
	)
	return parser


def main(argv: list[str] | None = None) -> None:
	parser = _build_argument_parser()
	args = parser.parse_args(argv)

	points = load_control_points(args.mod1_file)
	terrain = generate_terrain(points, resolution=args.resolution)
	output_dir: Path = args.output

	if args.scenario == "uniform":
		run_uniform_rise(terrain, output_dir, total_frames=args.frames)
	elif args.scenario == "wave":
		run_wave(terrain, output_dir, total_frames=args.frames)
	elif args.scenario == "rain":
		run_rain(terrain, output_dir, total_frames=args.frames)
	else:
		run_all(terrain, output_dir, frames=args.frames)

	print(f"Frames generated in {output_dir.resolve()}")
