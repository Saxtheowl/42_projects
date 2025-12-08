#include "render.h"

#define _GNU_SOURCE
#include <pthread.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static t_vec3	vec_add(t_vec3 a, t_vec3 b) { return (t_vec3){a.x + b.x, a.y + b.y, a.z + b.z}; }
static t_vec3	vec_sub(t_vec3 a, t_vec3 b) { return (t_vec3){a.x - b.x, a.y - b.y, a.z - b.z}; }
static t_vec3	vec_scale(t_vec3 v, double s) { return (t_vec3){v.x * s, v.y * s, v.z * s}; }
static double	vec_dot(t_vec3 a, t_vec3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
static double	vec_len(t_vec3 v) { return sqrt(vec_dot(v, v)); }
static t_vec3	vec_norm(t_vec3 v)
{
	double l = vec_len(v);
	if (l == 0)
		return v;
	return vec_scale(v, 1.0 / l);
}

static t_vec3	reflect(t_vec3 I, t_vec3 N)
{
	return vec_sub(I, vec_scale(N, 2.0 * vec_dot(I, N)));
}
static int	clamp_i(int v, int min, int max)
{
	if (v < min)
		return min;
	if (v > max)
		return max;
	return v;
}

typedef struct s_hit
{
	double t;
	t_vec3 point;
	t_vec3 normal;
	t_material mat;
}	t_hit;

static int	intersect_sphere(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	t_vec3 oc = vec_sub(ro, o->pos);
	double a = vec_dot(rd, rd);
	double b = 2.0 * vec_dot(oc, rd);
	double c = vec_dot(oc, oc) - o->radius * o->radius;
	double disc = b * b - 4 * a * c;
	if (disc < 0)
		return 0;
	double t0 = (-b - sqrt(disc)) / (2 * a);
	double t1 = (-b + sqrt(disc)) / (2 * a);
	double t = (t0 > 1e-4) ? t0 : t1;
	if (t < 1e-4)
		return 0;
	hit->t = t;
	hit->point = vec_add(ro, vec_scale(rd, t));
	hit->normal = vec_norm(vec_sub(hit->point, o->pos));
	hit->mat = o->mat;
	return 1;
}

static int	intersect_plane(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	t_vec3 n = vec_norm(o->dir);
	double denom = vec_dot(n, rd);
	if (fabs(denom) < 1e-6)
		return 0;
	double t = vec_dot(vec_sub(o->pos, ro), n) / denom;
	if (t < 1e-4)
		return 0;
	hit->t = t;
	hit->point = vec_add(ro, vec_scale(rd, t));
	hit->normal = (denom < 0) ? n : vec_scale(n, -1);
	hit->mat = o->mat;
	return 1;
}

static int	intersect_cylinder(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	t_vec3 ca = vec_norm(o->dir);
	t_vec3 oc = vec_sub(ro, o->pos);
	double card = vec_dot(ca, rd);
	double caoc = vec_dot(ca, oc);
	t_vec3 xrd = vec_sub(rd, vec_scale(ca, card));
	t_vec3 xoc = vec_sub(oc, vec_scale(ca, caoc));
	double a = vec_dot(xrd, xrd);
	double b = 2.0 * vec_dot(xrd, xoc);
	double c = vec_dot(xoc, xoc) - o->radius * o->radius;
	double disc = b * b - 4 * a * c;
	if (disc < 0 || fabs(a) < 1e-9)
		return 0;
	double t = (-b - sqrt(disc)) / (2 * a);
	if (t < 1e-4)
		t = (-b + sqrt(disc)) / (2 * a);
	if (t < 1e-4)
		return 0;
	double y = caoc + t * card;
	if (y < 0 || y > o->height)
		return 0;
	hit->t = t;
	hit->point = vec_add(ro, vec_scale(rd, t));
	t_vec3 proj = vec_add(o->pos, vec_scale(ca, y));
	hit->normal = vec_norm(vec_sub(hit->point, proj));
	hit->mat = o->mat;
	return 1;
}

static int	intersect_cone(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	double angle = o->angle * M_PI / 180.0;
	double k = tan(angle);
	t_vec3 ca = vec_norm(o->dir);
	t_vec3 co = vec_sub(ro, o->pos);
	double dv = vec_dot(rd, ca);
	double co_v = vec_dot(co, ca);
	t_vec3 xrd = vec_sub(rd, vec_scale(ca, dv));
	t_vec3 xco = vec_sub(co, vec_scale(ca, co_v));
	double a = vec_dot(xrd, xrd) - k * k * dv * dv;
	double b = 2.0 * (vec_dot(xrd, xco) - k * k * dv * co_v);
	double c = vec_dot(xco, xco) - k * k * co_v * co_v;
	double disc = b * b - 4 * a * c;
	if (disc < 0 || fabs(a) < 1e-9)
		return 0;
	double t = (-b - sqrt(disc)) / (2 * a);
	if (t < 1e-4)
		t = (-b + sqrt(disc)) / (2 * a);
	if (t < 1e-4)
		return 0;
	double y = co_v + t * dv;
	if (y < 0 || y > o->height)
		return 0;
	hit->t = t;
	hit->point = vec_add(ro, vec_scale(rd, t));
	t_vec3 proj = vec_add(o->pos, vec_scale(ca, y));
	t_vec3 n = vec_norm(vec_sub(vec_sub(hit->point, proj), vec_scale(ca, k * k * vec_len(vec_sub(hit->point, proj)))));
	hit->normal = n;
	hit->mat = o->mat;
	return 1;
}

static int	trace(const t_scene *scene, t_vec3 ro, t_vec3 rd, t_hit *closest)
{
	int hit_any = 0;
	closest->t = 1e30;
	for (size_t i = 0; i < scene->objects_count; ++i)
	{
		t_hit h;
		int ok = 0;
		t_object *o = &scene->objects[i];
		if (o->type == OBJ_SPHERE)
			ok = intersect_sphere(o, ro, rd, &h);
		else if (o->type == OBJ_PLANE)
			ok = intersect_plane(o, ro, rd, &h);
		else if (o->type == OBJ_CYLINDER)
			ok = intersect_cylinder(o, ro, rd, &h);
		else if (o->type == OBJ_CONE)
			ok = intersect_cone(o, ro, rd, &h);
		if (ok && h.t < closest->t)
		{
			hit_any = 1;
			*closest = h;
		}
	}
	return hit_any;
}

static int	in_shadow(const t_scene *scene, t_vec3 point, t_vec3 light_dir, double max_dist)
{
	t_hit h;
	if (trace(scene, vec_add(point, vec_scale(light_dir, 1e-3)), light_dir, &h))
		return h.t < max_dist;
	return 0;
}

static t_color	shade(const t_scene *scene, t_hit *hit, t_vec3 rd)
{
	double r = scene->ambient_intensity * hit->mat.color.r * scene->ambient_color.r / 255.0 / 255.0;
	double g = scene->ambient_intensity * hit->mat.color.g * scene->ambient_color.g / 255.0 / 255.0;
	double b = scene->ambient_intensity * hit->mat.color.b * scene->ambient_color.b / 255.0 / 255.0;

	for (size_t i = 0; i < scene->lights_count; ++i)
	{
		t_light *L = &scene->lights[i];
		t_vec3 ldir = vec_sub(L->pos, hit->point);
		double dist = vec_len(ldir);
		ldir = vec_scale(ldir, 1.0 / dist);
		if (in_shadow(scene, hit->point, ldir, dist))
			continue;
		double diff = fmax(0.0, vec_dot(hit->normal, ldir));
		t_vec3 view = vec_scale(rd, -1.0);
		t_vec3 reflect_dir = reflect(vec_scale(ldir, -1.0), hit->normal);
		double spec = pow(fmax(0.0, vec_dot(view, reflect_dir)), hit->mat.shininess);
		double lr = L->color.r / 255.0, lg = L->color.g / 255.0, lb = L->color.b / 255.0;
		r += L->intensity * (hit->mat.kd * diff * hit->mat.color.r / 255.0 * lr + hit->mat.ks * spec * lr);
		g += L->intensity * (hit->mat.kd * diff * hit->mat.color.g / 255.0 * lg + hit->mat.ks * spec * lg);
		b += L->intensity * (hit->mat.kd * diff * hit->mat.color.b / 255.0 * lb + hit->mat.ks * spec * lb);
	}
	t_color out = {
		.r = clamp_i((int)(r * 255.0), 0, 255),
		.g = clamp_i((int)(g * 255.0), 0, 255),
		.b = clamp_i((int)(b * 255.0), 0, 255)};
	return out;
}

static t_color	background_color(t_vec3 dir)
{
	double t = 0.5 * (dir.y + 1.0);
	t_color sky_top = {135, 206, 250};   /* light sky blue */
	t_color sky_bottom = {30, 30, 40};   /* dark horizon */
	t_color out;
	out.r = (int)((1.0 - t) * sky_bottom.r + t * sky_top.r);
	out.g = (int)((1.0 - t) * sky_bottom.g + t * sky_top.g);
	out.b = (int)((1.0 - t) * sky_bottom.b + t * sky_top.b);
	return out;
}

static t_vec3	random_in_unit_square(int px, int py, int s)
{
	/* simple hash-based jitter to avoid rand() */
	unsigned int seed = (unsigned int)(px * 1973u + py * 9277u + s * 26699u + 1u);
	seed ^= seed << 13;
	seed ^= seed >> 17;
	seed ^= seed << 5;
	double rx = (seed & 0xFFFF) / 65535.0;
	double ry = ((seed >> 16) & 0xFFFF) / 65535.0;
	return (t_vec3){rx, ry, 0};
}

static t_color	trace_ray(const t_scene *scene, t_vec3 ro, t_vec3 rd, int depth)
{
	t_hit hit;
	if (!trace(scene, ro, rd, &hit))
		return background_color(rd);
	t_color local = shade(scene, &hit, rd);
	if (depth <= 0 || hit.mat.reflect <= 1e-6)
		return local;
	t_vec3 refl_dir = reflect(vec_scale(rd, -1.0), hit.normal);
	t_color refl_col = trace_ray(scene, vec_add(hit.point, vec_scale(hit.normal, 1e-3)), refl_dir, depth - 1);
	double kr = hit.mat.reflect;
	t_color out;
	out.r = clamp_i((int)(local.r * (1.0 - kr) + refl_col.r * kr), 0, 255);
	out.g = clamp_i((int)(local.g * (1.0 - kr) + refl_col.g * kr), 0, 255);
	out.b = clamp_i((int)(local.b * (1.0 - kr) + refl_col.b * kr), 0, 255);
	return out;
}

typedef struct s_render_task
{
	const t_scene	*scene;
	t_color			*buffer;
	int				width;
	int				height;
	int				samples;
	int				y0;
	int				y1;
	t_vec3			forward;
	t_vec3			right;
	t_vec3			up;
	double			aspect;
	double			fov_scale;
}	t_render_task;

static void	*render_chunk(void *arg)
{
	t_render_task *t = (t_render_task *)arg;
	for (int y = t->y0; y < t->y1; ++y)
	{
		for (int x = 0; x < t->width; ++x)
		{
			double cr = 0, cg = 0, cb = 0;
			for (int s = 0; s < t->samples; ++s)
			{
				t_vec3 jitter = random_in_unit_square(x, y, s);
				double u = (x + (jitter.x - 0.5)) / t->width;
				double v = (y + (jitter.y - 0.5)) / t->height;
				double ndc_x = (2.0 * u - 1.0) * t->aspect * t->fov_scale;
				double ndc_y = (1.0 - 2.0 * v) * t->fov_scale;
				t_vec3 dir = vec_norm(vec_add(t->forward, vec_add(vec_scale(t->right, ndc_x), vec_scale(t->up, ndc_y))));
				t_color c = trace_ray(t->scene, t->scene->camera.pos, dir, 2);
				cr += c.r;
				cg += c.g;
				cb += c.b;
			}
			int idx = y * t->width + x;
			t->buffer[idx].r = (int)(cr / t->samples);
			t->buffer[idx].g = (int)(cg / t->samples);
			t->buffer[idx].b = (int)(cb / t->samples);
		}
	}
	return NULL;
}

static int	apply_gamma(int v, double gamma)
{
	double normalized = v / 255.0;
	if (normalized < 0.0)
		normalized = 0.0;
	if (normalized > 1.0)
		normalized = 1.0;
	return (int)(pow(normalized, 1.0 / gamma) * 255.0 + 0.5);
}

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma)
{
	FILE *f = fopen(path, "w");
	if (!f)
	{
		perror("fopen");
		return 0;
	}
	fprintf(f, "P3\n%d %d\n255\n", width, height);
	t_vec3 forward = vec_norm(scene->camera.dir);
	t_vec3 up = {0, 1, 0};
	if (fabs(vec_dot(up, forward)) > 0.99)
		up = (t_vec3){1, 0, 0};
	t_vec3 right = vec_norm((t_vec3){forward.y * up.z - forward.z * up.y,
									 forward.z * up.x - forward.x * up.z,
									 forward.x * up.y - forward.y * up.x});
	up = vec_norm((t_vec3){right.y * forward.z - right.z * forward.y,
						   right.z * forward.x - right.x * forward.z,
						   right.x * forward.y - right.y * forward.x});
	double aspect = (double)width / (double)height;
	double fov_scale = tan(scene->camera.fov * 0.5 * M_PI / 180.0);
	if (threads <= 0)
		threads = 4;
	if (threads > height)
		threads = height;
	if (threads < 1)
		threads = 1;
	pthread_t th[threads];
	t_render_task tasks[threads];
	t_color *buffer = calloc((size_t)width * (size_t)height, sizeof(t_color));
	if (!buffer)
	{
		perror("calloc");
		fclose(f);
		return 0;
	}
	int chunk = height / threads;
	for (int i = 0; i < threads; ++i)
	{
		tasks[i].scene = scene;
		tasks[i].buffer = buffer;
		tasks[i].width = width;
		tasks[i].height = height;
		tasks[i].samples = samples;
		tasks[i].y0 = i * chunk;
		tasks[i].y1 = (i == threads - 1) ? height : (i + 1) * chunk;
		tasks[i].forward = forward;
		tasks[i].right = right;
		tasks[i].up = up;
		tasks[i].aspect = aspect;
		tasks[i].fov_scale = fov_scale;
		if (pthread_create(&th[i], NULL, render_chunk, &tasks[i]) != 0)
			perror("pthread_create");
	}
	for (int i = 0; i < threads; ++i)
		pthread_join(th[i], NULL);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			t_color c = buffer[y * width + x];
			fprintf(f, "%d %d %d ", apply_gamma(c.r, gamma), apply_gamma(c.g, gamma), apply_gamma(c.b, gamma));
		}
		fprintf(f, "\n");
	}
	fclose(f);
	free(buffer);
	return 1;
}
