import unittest

from src.parser import load_control_points
from src.terrain import generate_terrain


def _nearest_index(values, target):
    return min(range(len(values)), key=lambda idx: abs(values[idx] - target))


class TerrainTests(unittest.TestCase):
    def test_interpolation_respects_bounds(self):
        points = load_control_points("resources/example.mod1")
        terrain = generate_terrain(points, resolution=32)

        # Height range must stay within the convex hull extrema (with small margin).
        self.assertGreaterEqual(terrain.min_height, -1.5)
        self.assertLessEqual(terrain.max_height, 11.5)

        # In the vicinity of the original control points, the interpolation should
        # match them closely.
        for expected_z, (target_x, target_y) in zip(
            [0.0, 5.0, 5.0, 10.0],
            [(0.0, 0.0), (10.0, 0.0), (0.0, 10.0), (10.0, 10.0)],
        ):
            idx_x = _nearest_index(terrain.x_coords, target_x)
            idx_y = _nearest_index(terrain.y_coords, target_y)
            self.assertAlmostEqual(
                terrain.heights[idx_y][idx_x],
                expected_z,
                places=1,
            )

        # Check the interpolated height around the centre of the terrain.
        centre_x = terrain.x_coords[len(terrain.x_coords) // 2]
        centre_y = terrain.y_coords[len(terrain.y_coords) // 2]
        centre_height = terrain.heights[len(terrain.y_coords) // 2][len(terrain.x_coords) // 2]
        expected_centre = 0.5 * (centre_x + centre_y)
        self.assertAlmostEqual(centre_height, expected_centre, places=1)


if __name__ == "__main__":
    unittest.main()
