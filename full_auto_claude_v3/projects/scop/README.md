# SCOP - 3D Object Viewer

Software 3D renderer for OBJ files with PPM output.

## Features

- OBJ file loading (vertices, faces)
- 4x4 transformation matrices
- Perspective projection
- Z-buffer depth testing
- Back-face culling
- Simple diffuse lighting
- Triangle rasterization

## Usage

```bash
# Render OBJ file
python scop.py model.obj

# Run demo with cube
python scop.py --demo
```

## Supported OBJ Features

- Vertices (`v x y z`)
- Faces (`f v1 v2 v3 ...`)
- Triangles and quads
- Automatic centering and scaling

## Transformations

- Translation
- Rotation (X, Y, Z)
- Scale
- Perspective projection

## Output

Renders to PPM image files with:
- Shaded triangles
- Depth-sorted faces
- Directional lighting

## Author

Implementation for 42 curriculum.
