#pragma once

#include <stddef.h>

typedef struct s_vec3
{
	double x;
	double y;
	double z;
}	t_vec3;

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
	t_color color;
}	t_material;

typedef struct s_camera
{
	t_vec3 pos;
	t_vec3 dir;
	double fov;
	int present;
}	t_camera;

typedef enum e_lighttype
{
	LIGHT_POINT,
	LIGHT_SPOT
}	t_lighttype;

typedef struct s_light
{
	t_vec3 pos;
	t_vec3 dir;
	double intensity;
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
	OBJ_BOX
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
	int checker_enabled;
	double checker_size;
	t_color checker_color;
	t_material mat;
}	t_object;

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
	t_light *lights;
	size_t lights_count;
	size_t lights_cap;
	t_object *objects;
	size_t objects_count;
	size_t objects_cap;
}	t_scene;

void	free_scene(t_scene *scene);
