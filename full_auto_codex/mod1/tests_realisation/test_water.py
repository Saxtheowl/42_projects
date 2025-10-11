import unittest

from src.terrain import Terrain
from src.water import (
	create_water_field,
	fill_uniform,
	flow_step,
	total_volume,
)


def _sample_terrain() -> Terrain:
	heights = [
		[0.0, 1.0, 2.0],
		[0.0, 1.0, 3.0],
		[0.0, 1.0, 4.0],
	]
	x_coords = [0.0, 1.0, 2.0]
	y_coords = [0.0, 1.0, 2.0]
	return Terrain(
		heights=heights,
		x_coords=x_coords,
		y_coords=y_coords,
		min_height=0.0,
		max_height=4.0,
	)


class WaterTests(unittest.TestCase):
	def test_uniform_fill(self):
		terrain = _sample_terrain()
		field = create_water_field(terrain)
		fill_uniform(terrain, field.depth, surface_level=2.5)
		self.assertAlmostEqual(field.depth[0][0], 2.5)
		self.assertAlmostEqual(field.depth[0][2], 0.5)
		self.assertAlmostEqual(field.depth[2][2], 0.0)

	def test_flow_step(self):
		terrain = _sample_terrain()
		field = create_water_field(terrain)
		# Create a localised water bump over the centre cell.
		field.depth[1][1] = 4.0
		initial_volume = total_volume(field.depth)
		flow_step(terrain, field.depth, rate=0.5, minimum_drop=0.0)
		# Water should have spread to neighbours.
		self.assertLess(field.depth[1][1], 4.0)
		self.assertGreater(field.depth[1][0], 0.0)
		self.assertGreater(field.depth[0][1], 0.0)
		# Volume must be conserved.
		self.assertAlmostEqual(initial_volume, total_volume(field.depth), places=6)


if __name__ == "__main__":
	unittest.main()
