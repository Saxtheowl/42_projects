#pragma once

#include <stddef.h>
#include <stdint.h>

typedef struct s_vec3
{
	double x;
	double y;
	double z;
}	t_vec3;

typedef struct s_vec2
{
	double u;
	double v;
}	t_vec2;

typedef struct s_color
{
	int r;
	int g;
	int b;
}	t_color;

typedef struct s_material
{
	double kd;
	double ks;
	int shininess;
	double reflect;
	double transparency;
	double ior;
	double roughness;
	double emission_strength;
	t_color emission_color;
	struct s_texture *texture;
	struct s_texture *normal_map;
	t_vec2 uv_scale;
	t_color color;
}	t_material;

typedef struct s_camera
{
	t_vec3 pos;
	t_vec3 dir;
	t_vec3 up;
	double fov;
	double aperture;
	double focal_dist;
	int present;
	int has_up;
}	t_camera;

typedef enum e_lighttype
{
	LIGHT_POINT,
	LIGHT_SPOT,
	LIGHT_DIR
}	t_lighttype;

typedef struct s_light
{
	t_vec3 pos;
	t_vec3 dir;
	double intensity;
	double radius;
	t_color color;
	t_lighttype type;
	double cutoff_cos;
}	t_light;

typedef enum e_objtype
{
	OBJ_SPHERE,
	OBJ_PLANE,
	OBJ_CYLINDER,
	OBJ_CONE,
	OBJ_BOX,
	OBJ_TRIANGLE
}	t_objtype;

typedef struct s_object
{
	t_objtype type;
	t_vec3 pos;
	t_vec3 dir;    /* used for plane/cylinder/cone */
	double radius; /* sphere/cylinder */
	double height; /* cylinder/cone */
	double angle;  /* cone angle in degrees */
	t_vec3 size;   /* box half-size */
	t_vec3 v0;     /* triangle vertices */
	t_vec3 v1;
	t_vec3 v2;
	t_vec2 uv0;
	t_vec2 uv1;
	t_vec2 uv2;
	t_vec3 vn0;    /* vertex normals (optional) */
	t_vec3 vn1;
	t_vec3 vn2;
	int has_vertex_normals;
	int has_uvs;
	int checker_enabled;
	double checker_size;
	t_color checker_color;
	t_material mat;
}	t_object;

typedef struct s_texture
{
	int					width;
	int					height;
	t_color				*pixels;
	struct s_texture	*next;
}	t_texture;

typedef struct s_scene
{
	t_camera camera;
	t_color ambient_color;
	double ambient_intensity;
	t_color sky_top;
	t_color sky_bottom;
	double fog_density;
	t_color fog_color;
	int fog_enabled;
	int ao_samples;
	double ao_radius;
	int srgb_textures;
	int glossy_samples;
	int env_samples;
	double env_intensity;
	const char *albedo_path;
	const char *position_path;
	const char *id_path;
	uint32_t base_seed;
	double position_range;
	double clamp_value;
	t_light *lights;
	size_t lights_count;
	size_t lights_cap;
	t_object *objects;
	size_t objects_count;
	size_t objects_cap;
	t_texture *textures;
	t_texture *env_tex;
	int enable_bvh;
}	t_scene;

void	free_scene(t_scene *scene);
#include <stdint.h>
