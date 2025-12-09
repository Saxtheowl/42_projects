#include "parser.h"

#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_CAP 8
#ifndef M_PI
# define M_PI 3.14159265358979323846
#endif

static void	trim_newline(char *s)
{
	size_t len = strlen(s);
	while (len && (s[len - 1] == '\n' || s[len - 1] == '\r'))
		s[--len] = '\0';
}

static int	count_tokens(char *line)
{
	int count = 0;
	char *tok = strtok(line, " \t");
	while (tok)
	{
		++count;
		tok = strtok(NULL, " \t");
	}
	return count;
}

static int	read_double(char **tok, double *out)
{
	if (!*tok)
		return 0;
	char *end = NULL;
	*out = strtod(*tok, &end);
	if (end == *tok || (*end && !isspace((unsigned char)*end)))
		return 0;
	*tok = strtok(NULL, " \t");
	return 1;
}

static int	read_int(char **tok, int *out)
{
	double tmp;
	if (!read_double(tok, &tmp))
		return 0;
	*out = (int)tmp;
	return 1;
}

static int	read_vec3(char **tok, t_vec3 *v)
{
	return read_double(tok, &v->x) && read_double(tok, &v->y) && read_double(tok, &v->z);
}

static int	read_color(char **tok, t_color *c)
{
	return read_int(tok, &c->r) && read_int(tok, &c->g) && read_int(tok, &c->b);
}

static t_vec3	normalize(t_vec3 v)
{
	double len = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	if (len == 0.0)
		return v;
	return (t_vec3){v.x / len, v.y / len, v.z / len};
}

static int	ensure_light_cap(t_scene *scene, size_t cap)
{
	if (scene->lights_cap >= cap)
		return 1;
	size_t new_cap = (scene->lights_cap == 0) ? INITIAL_CAP : scene->lights_cap * 2;
	if (new_cap < cap)
		new_cap = cap;
	t_light *nl = realloc(scene->lights, new_cap * sizeof(t_light));
	if (!nl)
		return 0;
	scene->lights = nl;
	scene->lights_cap = new_cap;
	return 1;
}

static int	ensure_obj_cap(t_scene *scene, size_t cap)
{
	if (scene->objects_cap >= cap)
		return 1;
	size_t new_cap = (scene->objects_cap == 0) ? INITIAL_CAP : scene->objects_cap * 2;
	if (new_cap < cap)
		new_cap = cap;
	t_object *no = realloc(scene->objects, new_cap * sizeof(t_object));
	if (!no)
		return 0;
	scene->objects = no;
	scene->objects_cap = new_cap;
	return 1;
}

static int	parse_camera(char **tok, t_scene *scene)
{
	if (scene->camera.present)
		return 0;
	if (!read_vec3(tok, &scene->camera.pos) || !read_vec3(tok, &scene->camera.dir) || !read_double(tok, &scene->camera.fov))
		return 0;
	scene->camera.aperture = 0.0;
	scene->camera.focal_dist = 1.0;
	if (*tok)
	{
		if (!read_double(tok, &scene->camera.aperture))
			return 0;
		if (scene->camera.aperture < 0.0)
			scene->camera.aperture = 0.0;
	}
	if (*tok)
	{
		if (!read_double(tok, &scene->camera.focal_dist))
			return 0;
		if (scene->camera.focal_dist <= 0.0)
			scene->camera.focal_dist = 1.0;
	}
	scene->camera.present = 1;
	return 1;
}

static int	parse_ambient(char **tok, t_scene *scene)
{
	if (!read_double(tok, &scene->ambient_intensity) || !read_color(tok, &scene->ambient_color))
		return 0;
	return 1;
}

static int	parse_fog(char **tok, t_scene *scene)
{
	if (!read_double(tok, &scene->fog_density) || !read_color(tok, &scene->fog_color))
		return 0;
	if (scene->fog_density < 0.0)
		scene->fog_density = 0.0;
	scene->fog_enabled = scene->fog_density > 0.0;
	return 1;
}

static int	parse_light(char **tok, t_scene *scene)
{
	if (!ensure_light_cap(scene, scene->lights_count + 1))
		return 0;
	t_light *l = &scene->lights[scene->lights_count];
	if (!read_vec3(tok, &l->pos) || !read_double(tok, &l->intensity) || !read_color(tok, &l->color))
		return 0;
	l->type = LIGHT_POINT;
	l->dir = (t_vec3){0, 0, 0};
	l->cutoff_cos = -1.0;
	l->radius = 0.0;
	if (*tok && !read_double(tok, &l->radius))
		return 0;
	if (l->radius < 0.0)
		l->radius = 0.0;
	scene->lights_count++;
	return 1;
}

static int	parse_spot(char **tok, t_scene *scene)
{
	if (!ensure_light_cap(scene, scene->lights_count + 1))
		return 0;
	t_light *l = &scene->lights[scene->lights_count];
	if (!read_vec3(tok, &l->pos) || !read_vec3(tok, &l->dir))
		return 0;
	l->dir = normalize(l->dir);
	double cutoff_deg;
	if (!read_double(tok, &cutoff_deg))
		return 0;
	if (!read_double(tok, &l->intensity) || !read_color(tok, &l->color))
		return 0;
	l->type = LIGHT_SPOT;
	l->cutoff_cos = cos(cutoff_deg * M_PI / 180.0);
	l->radius = 0.0;
	if (*tok && !read_double(tok, &l->radius))
		return 0;
	if (l->radius < 0.0)
		l->radius = 0.0;
	scene->lights_count++;
	return 1;
}

static int	fill_material(char **tok, t_material *m)
{
	if (!read_color(tok, &m->color))
		return 0;
	if (!read_double(tok, &m->kd) || !read_double(tok, &m->ks))
		return 0;
	if (!read_int(tok, &m->shininess))
		return 0;
	m->reflect = 0.0;
	m->transparency = 0.0;
	m->ior = 1.5;
	m->roughness = 0.0;
	if (*tok)
	{
		if (!read_double(tok, &m->reflect))
			return 0;
		if (m->reflect < 0.0)
			m->reflect = 0.0;
		if (m->reflect > 1.0)
			m->reflect = 1.0;
	}
	if (*tok)
	{
		if (!read_double(tok, &m->transparency))
			return 0;
		if (m->transparency < 0.0)
			m->transparency = 0.0;
		if (m->transparency > 1.0)
			m->transparency = 1.0;
	}
	if (*tok)
	{
		if (!read_double(tok, &m->ior))
			return 0;
		if (m->ior < 1.0)
			m->ior = 1.0;
	}
	if (*tok)
	{
		if (!read_double(tok, &m->roughness))
			return 0;
		if (m->roughness < 0.0)
			m->roughness = 0.0;
		if (m->roughness > 1.0)
			m->roughness = 1.0;
	}
	return 1;
}

static int	parse_object(char **tok, t_scene *scene, t_objtype type)
{
	if (!ensure_obj_cap(scene, scene->objects_count + 1))
		return 0;
	t_object *o = &scene->objects[scene->objects_count];
	memset(o, 0, sizeof(*o));
	o->type = type;
	o->checker_enabled = 0;
	if (type == OBJ_TRIANGLE)
	{
		if (!read_vec3(tok, &o->v0) || !read_vec3(tok, &o->v1) || !read_vec3(tok, &o->v2))
			return 0;
	}
	else
	{
		if (!read_vec3(tok, &o->pos))
			return 0;
	}
	if (type == OBJ_BOX)
		if (!read_vec3(tok, &o->size))
			return 0;
	if (type == OBJ_PLANE || type == OBJ_CYLINDER || type == OBJ_CONE)
		if (!read_vec3(tok, &o->dir))
			return 0;
	if (type == OBJ_SPHERE || type == OBJ_CYLINDER)
		if (!read_double(tok, &o->radius))
			return 0;
	if (type == OBJ_CONE)
		if (!read_double(tok, &o->angle))
			return 0;
	if (type == OBJ_CYLINDER || type == OBJ_CONE)
		if (!read_double(tok, &o->height))
			return 0;
	if (!fill_material(tok, &o->mat))
		return 0;
	if (type == OBJ_PLANE && *tok)
	{
		if (!read_double(tok, &o->checker_size) || !read_color(tok, &o->checker_color))
			return 0;
		if (o->checker_size <= 0.0)
			o->checker_size = 1.0;
		o->checker_enabled = 1;
	}
	scene->objects_count++;
	return 1;
}

static int	parse_face_index(const char *s, int *out)
{
	char buf[64];
	size_t i = 0;
	while (s[i] && s[i] != '/' && i + 1 < sizeof(buf))
	{
		buf[i] = s[i];
		++i;
	}
	buf[i] = '\0';
	char *end = NULL;
	long v = strtol(buf, &end, 10);
	if (end == buf || v <= 0)
		return 0;
	*out = (int)v;
	return 1;
}

static int	parse_mesh(char **tok, t_scene *scene)
{
	if (!*tok)
		return 0;
	const char *path = *tok;
	*tok = strtok(NULL, " \t");
	t_material mat;
	if (!fill_material(tok, &mat))
		return 0;
	t_vec3 scale = {1.0, 1.0, 1.0};
	t_vec3 translate = {0.0, 0.0, 0.0};
	if (*tok)
	{
		if (!read_vec3(tok, &scale))
			return 0;
		if (*tok)
		{
			if (!read_vec3(tok, &translate))
				return 0;
		}
	}
	FILE *f = fopen(path, "r");
	if (!f)
	{
		perror("fopen mesh");
		return 0;
	}
	size_t vcap = 16, vcount = 0;
	t_vec3 *verts = malloc(vcap * sizeof(t_vec3));
	if (!verts)
	{
		fclose(f);
		return 0;
	}
	char line[256];
	int ok = 1;
	while (ok && fgets(line, sizeof(line), f))
	{
		if (line[0] == 'v' && isspace((unsigned char)line[1]))
		{
			t_vec3 v;
			if (sscanf(line + 1, "%lf %lf %lf", &v.x, &v.y, &v.z) != 3)
			{
				ok = 0;
				break ;
			}
			if (vcount == vcap)
			{
				vcap *= 2;
				t_vec3 *nv = realloc(verts, vcap * sizeof(t_vec3));
				if (!nv)
				{
					ok = 0;
					break ;
				}
				verts = nv;
			}
			verts[vcount++] = v;
		}
		else if (line[0] == 'f' && isspace((unsigned char)line[1]))
		{
			char a[64], b[64], c[64];
			if (sscanf(line + 1, "%63s %63s %63s", a, b, c) != 3)
			{
				ok = 0;
				break ;
			}
			int ia, ib, ic;
			if (!parse_face_index(a, &ia) || !parse_face_index(b, &ib) || !parse_face_index(c, &ic))
			{
				ok = 0;
				break ;
			}
			if (ia < 1 || ib < 1 || ic < 1 || (size_t)ia > vcount || (size_t)ib > vcount || (size_t)ic > vcount)
			{
				ok = 0;
				break ;
			}
			if (!ensure_obj_cap(scene, scene->objects_count + 1))
			{
				ok = 0;
				break ;
			}
			t_object *o = &scene->objects[scene->objects_count++];
			memset(o, 0, sizeof(*o));
			o->type = OBJ_TRIANGLE;
			o->v0 = (t_vec3){verts[ia - 1].x * scale.x + translate.x,
							 verts[ia - 1].y * scale.y + translate.y,
							 verts[ia - 1].z * scale.z + translate.z};
			o->v1 = (t_vec3){verts[ib - 1].x * scale.x + translate.x,
							 verts[ib - 1].y * scale.y + translate.y,
							 verts[ib - 1].z * scale.z + translate.z};
			o->v2 = (t_vec3){verts[ic - 1].x * scale.x + translate.x,
							 verts[ic - 1].y * scale.y + translate.y,
							 verts[ic - 1].z * scale.z + translate.z};
			o->mat = mat;
		}
	}
	free(verts);
	fclose(f);
	return ok;
}

static int	dispatch(char *line, t_scene *scene, int lineno)
{
	if (*line == '\0' || *line == '#')
		return 1;
	char *tok = strtok(line, " \t");
	if (!tok)
		return 1;
	char *args = strtok(NULL, " \t");
	if (strcmp(tok, "camera") == 0)
		return parse_camera(&args, scene);
	if (strcmp(tok, "ambient") == 0)
		return parse_ambient(&args, scene);
	if (strcmp(tok, "fog") == 0)
		return parse_fog(&args, scene);
	if (strcmp(tok, "light") == 0)
		return parse_light(&args, scene);
	if (strcmp(tok, "spot") == 0)
		return parse_spot(&args, scene);
	if (strcmp(tok, "sphere") == 0)
		return parse_object(&args, scene, OBJ_SPHERE);
	if (strcmp(tok, "plane") == 0)
		return parse_object(&args, scene, OBJ_PLANE);
	if (strcmp(tok, "cylinder") == 0)
		return parse_object(&args, scene, OBJ_CYLINDER);
	if (strcmp(tok, "cone") == 0)
		return parse_object(&args, scene, OBJ_CONE);
	if (strcmp(tok, "box") == 0)
		return parse_object(&args, scene, OBJ_BOX);
	if (strcmp(tok, "triangle") == 0)
		return parse_object(&args, scene, OBJ_TRIANGLE);
	if (strcmp(tok, "mesh") == 0)
		return parse_mesh(&args, scene);
	fprintf(stderr, "Unknown token at line %d\n", lineno);
	return 0;
}

int	parse_scene(const char *path, t_scene *scene)
{
	FILE *f = fopen(path, "r");
	if (!f)
	{
		perror("fopen");
		return 0;
	}
	memset(scene, 0, sizeof(*scene));
	scene->sky_top = (t_color){135, 206, 250};
	scene->sky_bottom = (t_color){30, 30, 40};
	scene->fog_density = 0.0;
	scene->fog_color = (t_color){200, 200, 200};
	scene->fog_enabled = 0;
	scene->camera.aperture = 0.0;
	scene->camera.focal_dist = 1.0;
	char buf[1024];
	int ok = 1;
	int lineno = 0;
	while (ok && fgets(buf, sizeof(buf), f))
	{
		++lineno;
		trim_newline(buf);
		char linecpy[1024];
		strncpy(linecpy, buf, sizeof(linecpy) - 1);
		linecpy[sizeof(linecpy) - 1] = '\0';
		/* quick count to early reject */
		int tokens = count_tokens(linecpy);
		if (tokens == 0)
			continue;
		ok = dispatch(buf, scene, lineno);
	}
	if (ferror(f))
		ok = 0;
	fclose(f);
	if (!scene->camera.present)
	{
		fprintf(stderr, "Error: camera missing\n");
		ok = 0;
	}
	if (!ok)
		free_scene(scene);
	return ok;
}

void	free_scene(t_scene *scene)
{
	free(scene->lights);
	free(scene->objects);
	memset(scene, 0, sizeof(*scene));
}
