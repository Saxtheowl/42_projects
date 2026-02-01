# miniRT

Simple raytracer (PPM output).

## Description

A basic raytracer supporting spheres, planes, and cylinders with ambient and diffuse lighting. Outputs to PPM format.

## Features

- Geometric primitives: sphere, plane, cylinder
- Point lights with shadows
- Ambient lighting
- Diffuse shading
- Camera with configurable FOV
- PPM image output

## Usage

```bash
./minirt.py --demo [output.ppm]     # Render demo scene
./minirt.py scene.rt [output.ppm]   # Render from scene file
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `-w WIDTH` | Image width | 800 |
| `-h HEIGHT` | Image height | 600 |

## Demo Scene

The demo includes:
- Ground plane (green)
- Red, blue, green, and yellow spheres
- Orange cylinder
- Two point lights
- Sky gradient background

## Scene File Format (.rt)

```
A  0.2  255,255,255                    # Ambient: ratio R,G,B
C  0,2,-5  0,-0.2,1  60                # Camera: pos direction FOV
L  -5,10,-5  0.8  255,255,255          # Light: pos intensity R,G,B
sp 0,1,2  2.0  255,50,50               # Sphere: center diameter R,G,B
pl 0,0,0  0,1,0  50,100,50             # Plane: point normal R,G,B
cy -1,0,1  0,1,0  0.6  1.5  200,128,50 # Cylinder: base axis diam height R,G,B
```

## Examples

```bash
# Render demo at 1080p
./minirt.py --demo -w 1920 -h 1080 hd.ppm

# Quick preview
./minirt.py --demo -w 400 -h 300 preview.ppm
```

## Implementation

- Ray-sphere intersection
- Ray-plane intersection
- Ray-cylinder intersection
- Shadow rays for each light
- Lambertian diffuse shading

## Files

| File | Description |
|------|-------------|
| `minirt.py` | Main raytracer |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
