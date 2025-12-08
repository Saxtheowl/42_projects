#include "parser.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_CAP 8

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
	scene->camera.present = 1;
	return 1;
}

static int	parse_ambient(char **tok, t_scene *scene)
{
	if (!read_double(tok, &scene->ambient_intensity) || !read_color(tok, &scene->ambient_color))
		return 0;
	return 1;
}

static int	parse_light(char **tok, t_scene *scene)
{
	if (!ensure_light_cap(scene, scene->lights_count + 1))
		return 0;
	t_light *l = &scene->lights[scene->lights_count];
	if (!read_vec3(tok, &l->pos) || !read_double(tok, &l->intensity) || !read_color(tok, &l->color))
		return 0;
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
	if (*tok)
	{
		if (!read_double(tok, &m->reflect))
			return 0;
		if (m->reflect < 0.0)
			m->reflect = 0.0;
		if (m->reflect > 1.0)
			m->reflect = 1.0;
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
	if (!read_vec3(tok, &o->pos))
		return 0;
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
	if (strcmp(tok, "light") == 0)
		return parse_light(&args, scene);
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
