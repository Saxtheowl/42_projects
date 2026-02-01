#!/usr/bin/env python3
"""
SCOP - 3D Object Viewer
Loads OBJ files and renders to PPM using software rendering
"""

import sys
import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class Vec3:
    x: float
    y: float
    z: float

    def __add__(self, other):
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other):
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, scalar):
        return Vec3(self.x * scalar, self.y * scalar, self.z * scalar)

    def dot(self, other):
        return self.x * other.x + self.y * other.y + self.z * other.z

    def cross(self, other):
        return Vec3(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x
        )

    def normalize(self):
        length = math.sqrt(self.x**2 + self.y**2 + self.z**2)
        if length > 0:
            return Vec3(self.x/length, self.y/length, self.z/length)
        return Vec3(0, 0, 0)

    def length(self):
        return math.sqrt(self.x**2 + self.y**2 + self.z**2)


@dataclass
class Color:
    r: int
    g: int
    b: int

    def scale(self, factor):
        return Color(
            max(0, min(255, int(self.r * factor))),
            max(0, min(255, int(self.g * factor))),
            max(0, min(255, int(self.b * factor)))
        )


class Matrix4:
    """4x4 transformation matrix."""

    def __init__(self):
        self.m = [[0]*4 for _ in range(4)]
        for i in range(4):
            self.m[i][i] = 1

    @staticmethod
    def identity():
        return Matrix4()

    @staticmethod
    def rotation_x(angle):
        m = Matrix4()
        c, s = math.cos(angle), math.sin(angle)
        m.m[1][1] = c
        m.m[1][2] = -s
        m.m[2][1] = s
        m.m[2][2] = c
        return m

    @staticmethod
    def rotation_y(angle):
        m = Matrix4()
        c, s = math.cos(angle), math.sin(angle)
        m.m[0][0] = c
        m.m[0][2] = s
        m.m[2][0] = -s
        m.m[2][2] = c
        return m

    @staticmethod
    def rotation_z(angle):
        m = Matrix4()
        c, s = math.cos(angle), math.sin(angle)
        m.m[0][0] = c
        m.m[0][1] = -s
        m.m[1][0] = s
        m.m[1][1] = c
        return m

    @staticmethod
    def translation(x, y, z):
        m = Matrix4()
        m.m[0][3] = x
        m.m[1][3] = y
        m.m[2][3] = z
        return m

    @staticmethod
    def scale(sx, sy, sz):
        m = Matrix4()
        m.m[0][0] = sx
        m.m[1][1] = sy
        m.m[2][2] = sz
        return m

    @staticmethod
    def perspective(fov, aspect, near, far):
        m = Matrix4()
        f = 1 / math.tan(fov / 2)
        m.m[0][0] = f / aspect
        m.m[1][1] = f
        m.m[2][2] = (far + near) / (near - far)
        m.m[2][3] = (2 * far * near) / (near - far)
        m.m[3][2] = -1
        m.m[3][3] = 0
        return m

    def multiply(self, other):
        result = Matrix4()
        for i in range(4):
            for j in range(4):
                result.m[i][j] = sum(self.m[i][k] * other.m[k][j] for k in range(4))
        return result

    def transform(self, v: Vec3) -> Vec3:
        x = self.m[0][0]*v.x + self.m[0][1]*v.y + self.m[0][2]*v.z + self.m[0][3]
        y = self.m[1][0]*v.x + self.m[1][1]*v.y + self.m[1][2]*v.z + self.m[1][3]
        z = self.m[2][0]*v.x + self.m[2][1]*v.y + self.m[2][2]*v.z + self.m[2][3]
        w = self.m[3][0]*v.x + self.m[3][1]*v.y + self.m[3][2]*v.z + self.m[3][3]
        if abs(w) > 0.001:
            return Vec3(x/w, y/w, z/w)
        return Vec3(x, y, z)


class OBJModel:
    """OBJ file loader."""

    def __init__(self):
        self.vertices: List[Vec3] = []
        self.faces: List[List[int]] = []
        self.normals: List[Vec3] = []

    def load(self, filename: str):
        """Load OBJ file."""
        with open(filename, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if not parts:
                    continue

                if parts[0] == 'v':
                    x, y, z = float(parts[1]), float(parts[2]), float(parts[3])
                    self.vertices.append(Vec3(x, y, z))

                elif parts[0] == 'vn':
                    x, y, z = float(parts[1]), float(parts[2]), float(parts[3])
                    self.normals.append(Vec3(x, y, z))

                elif parts[0] == 'f':
                    face = []
                    for p in parts[1:]:
                        # Handle f v, f v/t, f v/t/n, f v//n
                        idx = int(p.split('/')[0]) - 1
                        face.append(idx)
                    self.faces.append(face)

        self._center_and_scale()
        self._compute_normals()

    def _center_and_scale(self):
        """Center model and scale to unit cube."""
        if not self.vertices:
            return

        # Find bounding box
        min_v = Vec3(float('inf'), float('inf'), float('inf'))
        max_v = Vec3(float('-inf'), float('-inf'), float('-inf'))

        for v in self.vertices:
            min_v.x = min(min_v.x, v.x)
            min_v.y = min(min_v.y, v.y)
            min_v.z = min(min_v.z, v.z)
            max_v.x = max(max_v.x, v.x)
            max_v.y = max(max_v.y, v.y)
            max_v.z = max(max_v.z, v.z)

        # Center
        center = Vec3(
            (min_v.x + max_v.x) / 2,
            (min_v.y + max_v.y) / 2,
            (min_v.z + max_v.z) / 2
        )

        # Scale
        size = max(max_v.x - min_v.x, max_v.y - min_v.y, max_v.z - min_v.z)
        scale = 2 / size if size > 0 else 1

        for i, v in enumerate(self.vertices):
            self.vertices[i] = Vec3(
                (v.x - center.x) * scale,
                (v.y - center.y) * scale,
                (v.z - center.z) * scale
            )

    def _compute_normals(self):
        """Compute face normals if not provided."""
        if self.normals:
            return

        for face in self.faces:
            if len(face) >= 3:
                v0 = self.vertices[face[0]]
                v1 = self.vertices[face[1]]
                v2 = self.vertices[face[2]]
                edge1 = v1 - v0
                edge2 = v2 - v0
                normal = edge1.cross(edge2).normalize()
                self.normals.append(normal)


class Renderer:
    """Software 3D renderer."""

    def __init__(self, width: int = 640, height: int = 480):
        self.width = width
        self.height = height
        self.framebuffer: List[List[Color]] = []
        self.zbuffer: List[List[float]] = []
        self.clear()

    def clear(self):
        """Clear framebuffer."""
        self.framebuffer = [[Color(20, 20, 40) for _ in range(self.width)]
                           for _ in range(self.height)]
        self.zbuffer = [[float('inf') for _ in range(self.width)]
                       for _ in range(self.height)]

    def draw_triangle(self, v0: Vec3, v1: Vec3, v2: Vec3, color: Color, light_dir: Vec3):
        """Draw filled triangle with lighting."""
        # Compute face normal
        edge1 = v1 - v0
        edge2 = v2 - v0
        normal = edge1.cross(edge2).normalize()

        # Back-face culling
        if normal.z < 0:
            return

        # Simple lighting
        intensity = max(0.2, normal.dot(light_dir))
        shaded_color = color.scale(intensity)

        # Convert to screen coordinates
        def to_screen(v):
            x = int((v.x + 1) * self.width / 2)
            y = int((1 - v.y) * self.height / 2)
            return (x, y, v.z)

        p0 = to_screen(v0)
        p1 = to_screen(v1)
        p2 = to_screen(v2)

        # Bounding box
        min_x = max(0, min(p0[0], p1[0], p2[0]))
        max_x = min(self.width - 1, max(p0[0], p1[0], p2[0]))
        min_y = max(0, min(p0[1], p1[1], p2[1]))
        max_y = min(self.height - 1, max(p0[1], p1[1], p2[1]))

        # Rasterize
        for y in range(min_y, max_y + 1):
            for x in range(min_x, max_x + 1):
                # Barycentric coordinates
                w0, w1, w2 = self._barycentric(x, y, p0, p1, p2)
                if w0 >= 0 and w1 >= 0 and w2 >= 0:
                    z = w0 * p0[2] + w1 * p1[2] + w2 * p2[2]
                    if z < self.zbuffer[y][x]:
                        self.zbuffer[y][x] = z
                        self.framebuffer[y][x] = shaded_color

    def _barycentric(self, x, y, p0, p1, p2):
        """Compute barycentric coordinates."""
        v0 = (p2[0] - p0[0], p2[1] - p0[1])
        v1 = (p1[0] - p0[0], p1[1] - p0[1])
        v2 = (x - p0[0], y - p0[1])

        dot00 = v0[0] * v0[0] + v0[1] * v0[1]
        dot01 = v0[0] * v1[0] + v0[1] * v1[1]
        dot02 = v0[0] * v2[0] + v0[1] * v2[1]
        dot11 = v1[0] * v1[0] + v1[1] * v1[1]
        dot12 = v1[0] * v2[0] + v1[1] * v2[1]

        denom = dot00 * dot11 - dot01 * dot01
        if abs(denom) < 0.0001:
            return (-1, -1, -1)

        u = (dot11 * dot02 - dot01 * dot12) / denom
        v = (dot00 * dot12 - dot01 * dot02) / denom

        return (1 - u - v, v, u)

    def render_model(self, model: OBJModel, transform: Matrix4):
        """Render OBJ model."""
        light_dir = Vec3(0.5, 0.5, 1).normalize()
        color = Color(200, 150, 100)

        # Transform vertices
        transformed = [transform.transform(v) for v in model.vertices]

        # Draw faces
        for i, face in enumerate(model.faces):
            if len(face) >= 3:
                v0 = transformed[face[0]]
                v1 = transformed[face[1]]
                v2 = transformed[face[2]]
                self.draw_triangle(v0, v1, v2, color, light_dir)

                # Triangulate quads
                if len(face) == 4:
                    v3 = transformed[face[3]]
                    self.draw_triangle(v0, v2, v3, color, light_dir)

    def save_ppm(self, filename: str):
        """Save framebuffer as PPM."""
        with open(filename, 'wb') as f:
            f.write(f"P6\n{self.width} {self.height}\n255\n".encode())
            for row in self.framebuffer:
                for pixel in row:
                    f.write(bytes([pixel.r, pixel.g, pixel.b]))


def create_cube_obj():
    """Create a simple cube OBJ file."""
    content = """# Cube
v -1 -1 -1
v  1 -1 -1
v  1  1 -1
v -1  1 -1
v -1 -1  1
v  1 -1  1
v  1  1  1
v -1  1  1
f 1 2 3 4
f 5 8 7 6
f 1 5 6 2
f 2 6 7 3
f 3 7 8 4
f 4 8 5 1
"""
    with open('cube.obj', 'w') as f:
        f.write(content)
    return 'cube.obj'


def run_demo():
    """Run demo."""
    print("SCOP - 3D Object Viewer Demo")
    print("=" * 40)

    # Create cube
    obj_file = create_cube_obj()
    print(f"Created {obj_file}")

    # Load model
    model = OBJModel()
    model.load(obj_file)
    print(f"Loaded {len(model.vertices)} vertices, {len(model.faces)} faces")

    # Create renderer
    renderer = Renderer(640, 480)

    # Render multiple angles
    angles = [0, 30, 60, 90, 120, 150]
    for i, angle in enumerate(angles):
        renderer.clear()

        # Create transformation
        rot_y = Matrix4.rotation_y(math.radians(angle))
        rot_x = Matrix4.rotation_x(math.radians(20))
        trans = Matrix4.translation(0, 0, -3)
        proj = Matrix4.perspective(math.radians(60), 640/480, 0.1, 100)

        transform = proj.multiply(trans).multiply(rot_x).multiply(rot_y)

        # Render
        renderer.render_model(model, transform)

        # Save
        filename = f"scop_frame_{i:02d}.ppm"
        renderer.save_ppm(filename)
        print(f"Rendered {filename} (angle: {angle}°)")

    print(f"\nGenerated {len(angles)} frames")
    print("View with: display scop_frame_00.ppm")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("SCOP - 3D Object Viewer")
        print("\nUsage:")
        print("  python scop.py <model.obj>  - Render OBJ file to PPM")
        print("  python scop.py --demo       - Run demo with cube")
        return

    if sys.argv[1] == '--demo':
        run_demo()
        return

    # Load and render model
    model = OBJModel()
    try:
        model.load(sys.argv[1])
    except FileNotFoundError:
        print(f"Error: File not found: {sys.argv[1]}")
        return

    print(f"Loaded {len(model.vertices)} vertices, {len(model.faces)} faces")

    # Render
    renderer = Renderer(800, 600)
    transform = Matrix4.perspective(math.radians(60), 800/600, 0.1, 100)
    transform = transform.multiply(Matrix4.translation(0, 0, -3))
    transform = transform.multiply(Matrix4.rotation_y(math.radians(30)))
    transform = transform.multiply(Matrix4.rotation_x(math.radians(20)))

    renderer.render_model(model, transform)

    output = 'scop_render.ppm'
    renderer.save_ppm(output)
    print(f"Rendered to {output}")


if __name__ == "__main__":
    main()
