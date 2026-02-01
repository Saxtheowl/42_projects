#!/usr/bin/env python3
"""
miniRT - Simple Raytracer (PPM output)
Supports spheres, planes, cylinders with ambient and diffuse lighting.
"""

import sys
import math
from typing import List, Tuple, Optional


class Vec3:
    def __init__(self, x: float = 0, y: float = 0, z: float = 0):
        self.x = x
        self.y = y
        self.z = z
    
    def __add__(self, other):
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)
    
    def __sub__(self, other):
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)
    
    def __mul__(self, scalar):
        return Vec3(self.x * scalar, self.y * scalar, self.z * scalar)
    
    def __truediv__(self, scalar):
        return Vec3(self.x / scalar, self.y / scalar, self.z / scalar)
    
    def __neg__(self):
        return Vec3(-self.x, -self.y, -self.z)
    
    def dot(self, other) -> float:
        return self.x * other.x + self.y * other.y + self.z * other.z
    
    def cross(self, other) -> 'Vec3':
        return Vec3(
            self.y * other.z - self.z * other.y,
            self.z * other.x - self.x * other.z,
            self.x * other.y - self.y * other.x
        )
    
    def length(self) -> float:
        return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    
    def normalize(self) -> 'Vec3':
        length = self.length()
        if length > 0:
            return self / length
        return Vec3()


class Ray:
    def __init__(self, origin: Vec3, direction: Vec3):
        self.origin = origin
        self.direction = direction.normalize()
    
    def at(self, t: float) -> Vec3:
        return self.origin + self.direction * t


class Color:
    def __init__(self, r: float = 0, g: float = 0, b: float = 0):
        self.r = max(0, min(1, r))
        self.g = max(0, min(1, g))
        self.b = max(0, min(1, b))
    
    def __add__(self, other):
        return Color(self.r + other.r, self.g + other.g, self.b + other.b)
    
    def __mul__(self, scalar):
        return Color(self.r * scalar, self.g * scalar, self.b * scalar)
    
    def to_rgb(self) -> Tuple[int, int, int]:
        return (
            int(max(0, min(255, self.r * 255))),
            int(max(0, min(255, self.g * 255))),
            int(max(0, min(255, self.b * 255)))
        )


class HitRecord:
    def __init__(self):
        self.point = Vec3()
        self.normal = Vec3()
        self.t = float('inf')
        self.color = Color()


class Sphere:
    def __init__(self, center: Vec3, radius: float, color: Color):
        self.center = center
        self.radius = radius
        self.color = color
    
    def hit(self, ray: Ray, t_min: float, t_max: float) -> Optional[HitRecord]:
        oc = ray.origin - self.center
        a = ray.direction.dot(ray.direction)
        b = 2.0 * oc.dot(ray.direction)
        c = oc.dot(oc) - self.radius * self.radius
        discriminant = b * b - 4 * a * c
        
        if discriminant < 0:
            return None
        
        t = (-b - math.sqrt(discriminant)) / (2.0 * a)
        if t < t_min or t > t_max:
            t = (-b + math.sqrt(discriminant)) / (2.0 * a)
            if t < t_min or t > t_max:
                return None
        
        rec = HitRecord()
        rec.t = t
        rec.point = ray.at(t)
        rec.normal = (rec.point - self.center).normalize()
        rec.color = self.color
        return rec


class Plane:
    def __init__(self, point: Vec3, normal: Vec3, color: Color):
        self.point = point
        self.normal = normal.normalize()
        self.color = color
    
    def hit(self, ray: Ray, t_min: float, t_max: float) -> Optional[HitRecord]:
        denom = self.normal.dot(ray.direction)
        if abs(denom) < 1e-6:
            return None
        
        t = (self.point - ray.origin).dot(self.normal) / denom
        if t < t_min or t > t_max:
            return None
        
        rec = HitRecord()
        rec.t = t
        rec.point = ray.at(t)
        rec.normal = self.normal if denom < 0 else -self.normal
        rec.color = self.color
        return rec


class Cylinder:
    def __init__(self, center: Vec3, axis: Vec3, radius: float, height: float, color: Color):
        self.center = center
        self.axis = axis.normalize()
        self.radius = radius
        self.height = height
        self.color = color
    
    def hit(self, ray: Ray, t_min: float, t_max: float) -> Optional[HitRecord]:
        oc = ray.origin - self.center
        d_proj = ray.direction - self.axis * ray.direction.dot(self.axis)
        oc_proj = oc - self.axis * oc.dot(self.axis)
        
        a = d_proj.dot(d_proj)
        b = 2.0 * d_proj.dot(oc_proj)
        c = oc_proj.dot(oc_proj) - self.radius * self.radius
        
        discriminant = b * b - 4 * a * c
        if discriminant < 0:
            return None
        
        t = (-b - math.sqrt(discriminant)) / (2.0 * a)
        if t < t_min or t > t_max:
            t = (-b + math.sqrt(discriminant)) / (2.0 * a)
            if t < t_min or t > t_max:
                return None
        
        point = ray.at(t)
        h = (point - self.center).dot(self.axis)
        if h < 0 or h > self.height:
            return None
        
        rec = HitRecord()
        rec.t = t
        rec.point = point
        rec.normal = (point - self.center - self.axis * h).normalize()
        rec.color = self.color
        return rec


class Light:
    def __init__(self, position: Vec3, intensity: float):
        self.position = position
        self.intensity = intensity


class Camera:
    def __init__(self, position: Vec3, direction: Vec3, fov: float, aspect_ratio: float):
        self.position = position
        self.direction = direction.normalize()
        self.fov = fov
        self.aspect_ratio = aspect_ratio
        
        # Calculate camera basis
        up = Vec3(0, 1, 0)
        if abs(self.direction.dot(up)) > 0.9:
            up = Vec3(1, 0, 0)
        
        self.right = self.direction.cross(up).normalize()
        self.up = self.right.cross(self.direction).normalize()
        
        self.half_width = math.tan(fov * math.pi / 360)
        self.half_height = self.half_width / aspect_ratio
    
    def get_ray(self, u: float, v: float) -> Ray:
        direction = (
            self.direction + 
            self.right * (u * self.half_width) + 
            self.up * (v * self.half_height)
        )
        return Ray(self.position, direction.normalize())


class Scene:
    def __init__(self):
        self.objects = []
        self.lights = []
        self.ambient = Color(0.1, 0.1, 0.1)
        self.camera = None
    
    def add_object(self, obj):
        self.objects.append(obj)
    
    def add_light(self, light: Light):
        self.lights.append(light)
    
    def set_ambient(self, intensity: float, color: Color):
        self.ambient = color * intensity
    
    def closest_hit(self, ray: Ray) -> Optional[HitRecord]:
        closest = None
        for obj in self.objects:
            hit = obj.hit(ray, 0.001, float('inf'))
            if hit and (closest is None or hit.t < closest.t):
                closest = hit
        return closest
    
    def is_shadowed(self, point: Vec3, light_pos: Vec3) -> bool:
        direction = light_pos - point
        distance = direction.length()
        ray = Ray(point, direction)
        hit = self.closest_hit(ray)
        return hit is not None and hit.t < distance
    
    def trace(self, ray: Ray) -> Color:
        hit = self.closest_hit(ray)
        if hit is None:
            # Background color
            t = 0.5 * (ray.direction.y + 1.0)
            return Color(1, 1, 1) * (1 - t) + Color(0.5, 0.7, 1.0) * t
        
        # Ambient light
        result = Color(
            hit.color.r * self.ambient.r,
            hit.color.g * self.ambient.g,
            hit.color.b * self.ambient.b
        )
        
        # Diffuse lighting
        for light in self.lights:
            if not self.is_shadowed(hit.point, light.position):
                light_dir = (light.position - hit.point).normalize()
                diffuse = max(0, hit.normal.dot(light_dir)) * light.intensity
                result = result + hit.color * diffuse
        
        return result


def render(scene: Scene, width: int, height: int) -> List[List[Tuple[int, int, int]]]:
    """Render the scene."""
    pixels = []
    
    for y in range(height):
        row = []
        for x in range(width):
            u = (2.0 * x / width - 1.0)
            v = (1.0 - 2.0 * y / height)
            
            ray = scene.camera.get_ray(u, v)
            color = scene.trace(ray)
            row.append(color.to_rgb())
        
        pixels.append(row)
        
        if y % 50 == 0:
            print(f"Rendering: {100 * y // height}%", file=sys.stderr)
    
    print("Rendering: 100%", file=sys.stderr)
    return pixels


def write_ppm(filename: str, pixels: List[List[Tuple[int, int, int]]]):
    """Write pixels to a PPM file."""
    height = len(pixels)
    width = len(pixels[0]) if height > 0 else 0
    
    with open(filename, 'w') as f:
        f.write(f"P3\n{width} {height}\n255\n")
        for row in pixels:
            for r, g, b in row:
                f.write(f"{r} {g} {b} ")
            f.write("\n")
    
    print(f"Saved to {filename}", file=sys.stderr)


def create_demo_scene() -> Scene:
    """Create a demo scene with various objects."""
    scene = Scene()
    
    # Camera
    scene.camera = Camera(
        Vec3(0, 2, -5),
        Vec3(0, -0.2, 1),
        60,
        4/3
    )
    
    # Ambient light
    scene.set_ambient(0.2, Color(1, 1, 1))
    
    # Lights
    scene.add_light(Light(Vec3(-5, 10, -5), 0.8))
    scene.add_light(Light(Vec3(5, 8, -2), 0.4))
    
    # Ground plane
    scene.add_object(Plane(
        Vec3(0, 0, 0),
        Vec3(0, 1, 0),
        Color(0.3, 0.5, 0.3)
    ))
    
    # Spheres
    scene.add_object(Sphere(
        Vec3(0, 1, 2),
        1.0,
        Color(1, 0.2, 0.2)
    ))
    
    scene.add_object(Sphere(
        Vec3(-2.5, 0.5, 3),
        0.5,
        Color(0.2, 0.2, 1)
    ))
    
    scene.add_object(Sphere(
        Vec3(2, 0.7, 2.5),
        0.7,
        Color(0.2, 1, 0.2)
    ))
    
    scene.add_object(Sphere(
        Vec3(1, 0.4, 0.5),
        0.4,
        Color(1, 1, 0.2)
    ))
    
    # Cylinder
    scene.add_object(Cylinder(
        Vec3(-1.5, 0, 1),
        Vec3(0, 1, 0),
        0.3,
        1.5,
        Color(0.8, 0.5, 0.2)
    ))
    
    return scene


def main():
    if len(sys.argv) < 2:
        print("Usage: minirt.py <scene.rt> [output.ppm]")
        print("       minirt.py --demo [output.ppm] [options]")
        print()
        print("Options:")
        print("  -w WIDTH    Image width (default: 800)")
        print("  -h HEIGHT   Image height (default: 600)")
        print()
        print("Scene file format (.rt):")
        print("  A  ratio R,G,B                     # Ambient light")
        print("  C  x,y,z  dx,dy,dz  FOV            # Camera")
        print("  L  x,y,z  intensity  R,G,B         # Point light")
        print("  sp x,y,z  diameter  R,G,B          # Sphere")
        print("  pl x,y,z  nx,ny,nz  R,G,B          # Plane")
        print("  cy x,y,z  ax,ay,az  diameter height R,G,B  # Cylinder")
        return
    
    width = 800
    height = 600
    output = "output.ppm"
    demo = False
    
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "--demo":
            demo = True
            i += 1
        elif arg == "-w" and i + 1 < len(sys.argv):
            width = int(sys.argv[i + 1])
            i += 2
        elif arg == "-h" and i + 1 < len(sys.argv):
            height = int(sys.argv[i + 1])
            i += 2
        elif arg.endswith(".ppm"):
            output = arg
            i += 1
        else:
            i += 1
    
    print(f"Rendering {width}x{height}...", file=sys.stderr)
    
    if demo:
        scene = create_demo_scene()
    else:
        # TODO: Parse .rt scene file
        scene = create_demo_scene()
    
    scene.camera.aspect_ratio = width / height
    
    pixels = render(scene, width, height)
    write_ppm(output, pixels)


if __name__ == "__main__":
    main()
