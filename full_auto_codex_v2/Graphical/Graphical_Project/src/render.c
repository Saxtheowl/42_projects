#include "render.h"

#define _GNU_SOURCE
#include <pthread.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static t_vec3	vec_add(t_vec3 a, t_vec3 b) { return (t_vec3){a.x + b.x, a.y + b.y, a.z + b.z}; }
static t_vec3	vec_sub(t_vec3 a, t_vec3 b) { return (t_vec3){a.x - b.x, a.y - b.y, a.z - b.z}; }
static t_vec3	vec_scale(t_vec3 v, double s) { return (t_vec3){v.x * s, v.y * s, v.z * s}; }
static double	vec_dot(t_vec3 a, t_vec3 b) { return a.x * b.x + a.y * b.y + a.z * b.z; }
static double	vec_len(t_vec3 v) { return sqrt(vec_dot(v, v)); }
static t_vec3	vec_cross(t_vec3 a, t_vec3 b)
{
	return (t_vec3){
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x};
}
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

static int	refract(t_vec3 I, t_vec3 N, double eta, t_vec3 *refr)
{
	double cosi = -vec_dot(I, N);
	double cost2 = 1.0 - eta * eta * (1.0 - cosi * cosi);
	if (cost2 < 0.0)
		return 0;
	*refr = vec_add(vec_scale(I, eta), vec_scale(N, eta * cosi - sqrt(cost2)));
	return 1;
}
static int	clamp_i(int v, int min, int max)
{
	if (v < min)
		return min;
	if (v > max)
		return max;
	return v;
}

static double	hash_u32(uint32_t x);
static t_vec3	random_in_unit_sphere(uint32_t seed);

typedef struct s_hit
{
	double t;
	t_vec3 point;
	t_vec3 normal;
	int has_uv;
	double bu;
	double bv;
	t_material mat;
	const t_object *obj;
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
	hit->obj = o;
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
	hit->obj = o;
	return 1;
}

static int	intersect_cap(t_vec3 center, t_vec3 normal, double radius, t_vec3 ro, t_vec3 rd, t_hit *hit, const t_material *mat)
{
	double denom = vec_dot(normal, rd);
	if (fabs(denom) < 1e-6)
		return 0;
	double t = vec_dot(vec_sub(center, ro), normal) / denom;
	if (t < 1e-4)
		return 0;
	t_vec3 p = vec_add(ro, vec_scale(rd, t));
	double d = vec_len(vec_sub(p, center));
	if (d > radius + 1e-6)
		return 0;
	hit->t = t;
	hit->point = p;
	hit->normal = (denom < 0) ? normal : vec_scale(normal, -1);
	hit->mat = *mat;
	hit->obj = NULL;
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
	int hit_any = 0;
	t_hit best;
	if (y >= 0 && y <= o->height)
	{
		hit_any = 1;
		best.t = t;
		best.point = vec_add(ro, vec_scale(rd, t));
		t_vec3 proj = vec_add(o->pos, vec_scale(ca, y));
		best.normal = vec_norm(vec_sub(best.point, proj));
		best.mat = o->mat;
		best.obj = o;
	}
	t_hit caphit;
	if (intersect_cap(o->pos, ca, o->radius, ro, rd, &caphit, &o->mat) && (!hit_any || caphit.t < best.t))
	{
		best = caphit;
		best.obj = o;
		hit_any = 1;
	}
	t_vec3 top_center = vec_add(o->pos, vec_scale(ca, o->height));
	if (intersect_cap(top_center, ca, o->radius, ro, rd, &caphit, &o->mat) && (!hit_any || caphit.t < best.t))
	{
		best = caphit;
		best.obj = o;
		hit_any = 1;
	}
	if (hit_any)
		*hit = best;
	return hit_any;
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
	int hit_any = 0;
	t_hit best;
	if (y >= 0 && y <= o->height)
	{
		hit_any = 1;
		best.t = t;
		best.point = vec_add(ro, vec_scale(rd, t));
		t_vec3 proj = vec_add(o->pos, vec_scale(ca, y));
		t_vec3 n = vec_norm(vec_sub(vec_sub(best.point, proj), vec_scale(ca, k * k * vec_len(vec_sub(best.point, proj)))));
		best.normal = n;
		best.mat = o->mat;
		best.obj = o;
	}
	/* base cap */
	t_vec3 base_center = vec_add(o->pos, vec_scale(ca, o->height));
	double base_radius = o->height * k;
	t_hit caphit;
	if (intersect_cap(base_center, ca, base_radius, ro, rd, &caphit, &o->mat) && (!hit_any || caphit.t < best.t))
	{
		best = caphit;
		best.obj = o;
		hit_any = 1;
	}
	if (hit_any)
		*hit = best;
	return hit_any;
}

static int	intersect_box(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	/* axis-aligned box centered at o->pos with half-size o->size */
	t_vec3 min = {o->pos.x - o->size.x, o->pos.y - o->size.y, o->pos.z - o->size.z};
	t_vec3 max = {o->pos.x + o->size.x, o->pos.y + o->size.y, o->pos.z + o->size.z};
	double tmin = -1e30, tmax = 1e30;
	for (int axis = 0; axis < 3; ++axis)
	{
		double origin = (&ro.x)[axis];
		double dir = (&rd.x)[axis];
		double inv = (dir != 0.0) ? 1.0 / dir : 1e30;
		double t1 = ((&min.x)[axis] - origin) * inv;
		double t2 = ((&max.x)[axis] - origin) * inv;
		if (t1 > t2)
		{
			double tmp = t1;
			t1 = t2;
			t2 = tmp;
		}
		if (t1 > tmin)
			tmin = t1;
		if (t2 < tmax)
			tmax = t2;
		if (tmin > tmax || tmax < 1e-4)
			return 0;
	}
	double t = tmin > 1e-4 ? tmin : tmax;
	if (t < 1e-4)
		return 0;
	t_vec3 p = vec_add(ro, vec_scale(rd, t));
	t_vec3 normal = {0, 0, 0};
	const double eps = 1e-4;
	if (fabs(p.x - min.x) < eps)
		normal = (t_vec3){-1, 0, 0};
	else if (fabs(p.x - max.x) < eps)
		normal = (t_vec3){1, 0, 0};
	else if (fabs(p.y - min.y) < eps)
		normal = (t_vec3){0, -1, 0};
	else if (fabs(p.y - max.y) < eps)
		normal = (t_vec3){0, 1, 0};
	else if (fabs(p.z - min.z) < eps)
		normal = (t_vec3){0, 0, -1};
	else if (fabs(p.z - max.z) < eps)
		normal = (t_vec3){0, 0, 1};
	else
		normal = vec_norm(vec_sub(p, o->pos));
	hit->t = t;
	hit->point = p;
	hit->normal = normal;
	hit->mat = o->mat;
	hit->obj = o;
	return 1;
}

static int	intersect_triangle(const t_object *o, t_vec3 ro, t_vec3 rd, t_hit *hit)
{
	const double EPS = 1e-6;
	t_vec3 v0v1 = vec_sub(o->v1, o->v0);
	t_vec3 v0v2 = vec_sub(o->v2, o->v0);
	t_vec3 pvec = vec_cross(rd, v0v2);
	double det = vec_dot(v0v1, pvec);
	if (fabs(det) < EPS)
		return 0;
	double invDet = 1.0 / det;
	t_vec3 tvec = vec_sub(ro, o->v0);
	double u = vec_dot(tvec, pvec) * invDet;
	if (u < 0.0 || u > 1.0)
		return 0;
	t_vec3 qvec = vec_cross(tvec, v0v1);
	double v = vec_dot(rd, qvec) * invDet;
	if (v < 0.0 || u + v > 1.0)
		return 0;
	double t = vec_dot(v0v2, qvec) * invDet;
	if (t < 1e-4)
		return 0;
	t_vec3 n;
	if (o->has_vertex_normals)
	{
		double w = 1.0 - u - v;
		n = vec_norm((t_vec3){
				o->vn0.x * w + o->vn1.x * u + o->vn2.x * v,
				o->vn0.y * w + o->vn1.y * u + o->vn2.y * v,
				o->vn0.z * w + o->vn1.z * u + o->vn2.z * v});
	}
	else
		n = vec_norm(vec_cross(v0v1, v0v2));
	hit->t = t;
	hit->point = vec_add(ro, vec_scale(rd, t));
	hit->normal = n;
	hit->has_uv = 0;
	if (o->has_uvs)
	{
		hit->has_uv = 1;
		hit->bu = u;
		hit->bv = v;
	}
	hit->mat = o->mat;
	hit->obj = o;
	return 1;
}

static int	trace(const t_scene *scene, t_vec3 ro, t_vec3 rd, t_hit *closest)
{
	int hit_any = 0;
	closest->t = 1e30;
	for (size_t i = 0; i < scene->objects_count; ++i)
	{
		t_hit h;
		memset(&h, 0, sizeof(h));
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
		else if (o->type == OBJ_BOX)
			ok = intersect_box(o, ro, rd, &h);
		else if (o->type == OBJ_TRIANGLE)
			ok = intersect_triangle(o, ro, rd, &h);
		if (ok)
		{
			if (!h.obj)
				h.obj = o;
			if (h.t < closest->t)
			{
				hit_any = 1;
				*closest = h;
			}
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

static void	apply_checker(const t_object *obj, t_hit *hit)
{
	if (!obj || obj->type != OBJ_PLANE || !obj->checker_enabled)
		return;
	t_vec3 n = obj->dir;
	n = vec_norm(n);
	t_vec3 tangent = fabs(n.x) > 0.9 ? (t_vec3){0, 1, 0} : (t_vec3){1, 0, 0};
	tangent = vec_norm(vec_cross(tangent, n));
	t_vec3 bitangent = vec_norm(vec_cross(n, tangent));
	t_vec3 rel = vec_sub(hit->point, obj->pos);
	double u = vec_dot(rel, tangent) / obj->checker_size;
	double v = vec_dot(rel, bitangent) / obj->checker_size;
	long long iu = (long long)floor(u);
	long long iv = (long long)floor(v);
	int pattern = (iu + iv) & 1;
	if (pattern)
		hit->mat.color = obj->checker_color;
}

static t_color	shade(const t_scene *scene, t_hit *hit, t_vec3 rd)
{
	/* textures */
	if (hit->mat.texture)
	{
		if (hit->obj && hit->obj->type == OBJ_SPHERE)
		{
			t_vec3 p = vec_norm(vec_sub(hit->point, hit->obj->pos));
			double u = 0.5 + atan2(p.z, p.x) / (2 * M_PI);
			double v = 0.5 - asin(p.y) / M_PI;
			hit->mat.color = sample_texture(hit->mat.texture, u, v);
		}
		else if (hit->obj && hit->obj->type == OBJ_PLANE)
		{
			t_vec3 n = vec_norm(hit->obj->dir);
			t_vec3 tangent = fabs(n.x) > 0.9 ? (t_vec3){0, 1, 0} : (t_vec3){1, 0, 0};
			tangent = vec_norm(vec_cross(tangent, n));
			t_vec3 bitangent = vec_norm(vec_cross(n, tangent));
			t_vec3 rel = vec_sub(hit->point, hit->obj->pos);
			double u = vec_dot(rel, tangent);
			double v = vec_dot(rel, bitangent);
			hit->mat.color = sample_texture(hit->mat.texture, u, v);
		}
		else if (hit->obj && hit->obj->type == OBJ_TRIANGLE && hit->has_uv)
		{
			double w = 1.0 - hit->bu - hit->bv;
			double u = hit->obj->uv0.u * w + hit->obj->uv1.u * hit->bu + hit->obj->uv2.u * hit->bv;
			double v = hit->obj->uv0.v * w + hit->obj->uv1.v * hit->bu + hit->obj->uv2.v * hit->bv;
			hit->mat.color = sample_texture(hit->mat.texture, u, v);
		}
	}
	apply_checker(hit->obj, hit);
	double r = scene->ambient_intensity * hit->mat.color.r * scene->ambient_color.r / 255.0 / 255.0;
	double g = scene->ambient_intensity * hit->mat.color.g * scene->ambient_color.g / 255.0 / 255.0;
	double b = scene->ambient_intensity * hit->mat.color.b * scene->ambient_color.b / 255.0 / 255.0;

	if (hit->mat.emission_strength > 1e-9)
	{
		r += hit->mat.emission_strength * (hit->mat.emission_color.r / 255.0);
		g += hit->mat.emission_strength * (hit->mat.emission_color.g / 255.0);
		b += hit->mat.emission_strength * (hit->mat.emission_color.b / 255.0);
	}

	for (size_t i = 0; i < scene->lights_count; ++i)
	{
		t_light *L = &scene->lights[i];
		int samples = (L->radius > 1e-6) ? 4 : 1;
		for (int s = 0; s < samples; ++s)
		{
			t_vec3 lp = L->pos;
			if (L->radius > 1e-6)
			{
				uint32_t seed = (uint32_t)(i * 73856093u + s * 19349663u + (uint32_t)(fabs(hit->point.x * 9973.0)));
				t_vec3 jitter = random_in_unit_sphere(seed);
				lp = vec_add(lp, vec_scale(jitter, L->radius));
			}
			t_vec3 ldir = vec_sub(lp, hit->point);
			double dist = vec_len(ldir);
			ldir = vec_scale(ldir, 1.0 / dist);
			if (L->type == LIGHT_SPOT)
			{
				double cos_theta = vec_dot(vec_scale(ldir, -1.0), L->dir);
				if (cos_theta < L->cutoff_cos)
					continue;
			}
			if (in_shadow(scene, hit->point, ldir, dist))
				continue;
			double attenuation = 1.0 / (1.0 + 0.09 * dist + 0.032 * dist * dist);
			double spot_factor = 1.0;
			if (L->type == LIGHT_SPOT)
				spot_factor = fmax(0.0, vec_dot(vec_scale(ldir, -1.0), L->dir));
			double diff = fmax(0.0, vec_dot(hit->normal, ldir));
			t_vec3 view = vec_scale(rd, -1.0);
			t_vec3 reflect_dir = reflect(vec_scale(ldir, -1.0), hit->normal);
			double spec = pow(fmax(0.0, vec_dot(view, reflect_dir)), hit->mat.shininess);
			double lr = L->color.r / 255.0, lg = L->color.g / 255.0, lb = L->color.b / 255.0;
			double scale = L->intensity * attenuation * spot_factor / samples;
			r += scale * (hit->mat.kd * diff * hit->mat.color.r / 255.0 * lr + hit->mat.ks * spec * lr);
			g += scale * (hit->mat.kd * diff * hit->mat.color.g / 255.0 * lg + hit->mat.ks * spec * lg);
			b += scale * (hit->mat.kd * diff * hit->mat.color.b / 255.0 * lb + hit->mat.ks * spec * lb);
		}
	}
	t_color out = {
		.r = clamp_i((int)(r * 255.0), 0, 255),
		.g = clamp_i((int)(g * 255.0), 0, 255),
		.b = clamp_i((int)(b * 255.0), 0, 255)};
	return out;
}

static t_color	background_color(const t_scene *scene, t_vec3 dir)
{
	double t = 0.5 * (dir.y + 1.0);
	t_color sky_top = scene->sky_top;
	t_color sky_bottom = scene->sky_bottom;
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

static t_vec3	random_in_unit_disk(int px, int py, int s)
{
	t_vec3 r = random_in_unit_square(px, py, s);
	double theta = 2.0 * M_PI * r.x;
	double rlen = sqrt(r.y);
	return (t_vec3){cos(theta) * rlen, sin(theta) * rlen, 0.0};
}

static double	hash_u32(uint32_t x)
{
	x ^= x >> 17;
	x *= 0xed5ad4bbU;
	x ^= x >> 11;
	x *= 0xac4c1b51U;
	x ^= x >> 15;
	x *= 0x31848babU;
	x ^= x >> 14;
	return (x & 0xFFFFFF) / 16777216.0;
}

static t_vec3	random_in_unit_sphere(uint32_t seed)
{
	double u = hash_u32(seed);
	double v = hash_u32(seed * 1664525u + 1013904223u);
	double theta = 2.0 * M_PI * u;
	double cosphi = 1.0 - 2.0 * v;
	double sinphi = sqrt(fmax(0.0, 1.0 - cosphi * cosphi));
	double r = cbrt(hash_u32(seed * 747796405u + 2891336453u));
	return (t_vec3){r * sinphi * cos(theta), r * sinphi * sin(theta), r * cosphi};
}

t_color	sample_texture(const t_texture *tex, double u, double v)
{
	if (!tex || !tex->pixels || tex->width <= 0 || tex->height <= 0)
		return (t_color){0, 0, 0};
	u = u - floor(u);
	v = v - floor(v);
	int x = (int)(u * tex->width) % tex->width;
	int y = (int)(v * tex->height) % tex->height;
	int idx = y * tex->width + x;
	return tex->pixels[idx];
}

static t_color	trace_ray(const t_scene *scene, t_vec3 ro, t_vec3 rd, int depth)
{
	t_hit hit;
	if (!trace(scene, ro, rd, &hit))
		return background_color(scene, rd);
	t_color local = shade(scene, &hit, rd);
	if (scene->fog_enabled && scene->fog_density > 0.0)
	{
		double f = 1.0 - exp(-scene->fog_density * hit.t);
		f = f < 0.0 ? 0.0 : (f > 1.0 ? 1.0 : f);
		local.r = clamp_i((int)(local.r * (1.0 - f) + scene->fog_color.r * f), 0, 255);
		local.g = clamp_i((int)(local.g * (1.0 - f) + scene->fog_color.g * f), 0, 255);
		local.b = clamp_i((int)(local.b * (1.0 - f) + scene->fog_color.b * f), 0, 255);
	}
	if (depth <= 0)
		return local;
	double kr = hit.mat.reflect;
	double kt = hit.mat.transparency;
	if (kr <= 1e-6 && kt <= 1e-6)
		return local;
	double cosi = fabs(vec_dot(rd, hit.normal));
	double etai = 1.0, etat = hit.mat.ior;
	if (vec_dot(rd, hit.normal) > 0.0)
	{
		double tmp = etai;
		etai = etat;
		etat = tmp;
	}
	double r0 = (etai - etat) / (etai + etat);
	r0 = r0 * r0;
	double fresnel = r0 + (1.0 - r0) * pow(1.0 - cosi, 5.0);
	double refl_weight = kr + (1.0 - kr) * fresnel;
	if (refl_weight > 1.0)
		refl_weight = 1.0;
	double trans_weight = kt * (1.0 - refl_weight);
	if (trans_weight < 0.0)
		trans_weight = 0.0;
	double base = 1.0 - refl_weight - trans_weight;
	if (base < 0.0)
		base = 0.0;
	t_vec3 refl_dir = reflect(vec_scale(rd, -1.0), hit.normal);
	if (hit.mat.roughness > 1e-6)
	{
		uint32_t seed = (uint32_t)(fabs(hit.point.x * 73856093.0) + fabs(hit.point.y * 19349663.0) + fabs(hit.point.z * 83492791.0) + (uint32_t)depth * 2654435761u);
		t_vec3 jitter = random_in_unit_sphere(seed);
		refl_dir = vec_norm(vec_add(refl_dir, vec_scale(jitter, hit.mat.roughness)));
	}
	t_color refl_col = trace_ray(scene, vec_add(hit.point, vec_scale(hit.normal, 1e-3)), refl_dir, depth - 1);
	t_color refr_col = {0, 0, 0};
	if (kt > 1e-6)
	{
		double eta = 1.0 / hit.mat.ior;
		t_vec3 n = hit.normal;
		double cosi = vec_dot(rd, hit.normal);
		if (cosi > 0.0)
		{
			n = vec_scale(n, -1.0);
			eta = hit.mat.ior;
		}
		t_vec3 refr_dir;
		if (refract(vec_scale(rd, -1.0), n, eta, &refr_dir))
			refr_col = trace_ray(scene, vec_add(hit.point, vec_scale(refr_dir, 1e-3)), refr_dir, depth - 1);
		else
			kt = 0.0;
	}
	t_color out;
	out.r = clamp_i((int)(local.r * base + refl_col.r * refl_weight + refr_col.r * trans_weight), 0, 255);
	out.g = clamp_i((int)(local.g * base + refl_col.g * refl_weight + refr_col.g * trans_weight), 0, 255);
	out.b = clamp_i((int)(local.b * base + refl_col.b * refl_weight + refr_col.b * trans_weight), 0, 255);
	return out;
}

typedef struct s_render_task
{
	const t_scene	*scene;
	t_color			*buffer;
	double			*depths;
	t_vec3			*normals;
	int				width;
	int				height;
	int				samples;
	int				max_depth;
	int				y0;
	int				y1;
	t_vec3			forward;
	t_vec3			right;
	t_vec3			up;
	double			aspect;
	double			fov_scale;
	double			aperture;
	double			focal_dist;
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
				t_vec3 ro = t->scene->camera.pos;
				if (t->aperture > 1e-6)
				{
					t_vec3 rdisk = random_in_unit_disk(x, y, s);
					double lens_radius = t->aperture * 0.5;
					t_vec3 offset = vec_add(vec_scale(t->right, rdisk.x * lens_radius), vec_scale(t->up, rdisk.y * lens_radius));
					t_vec3 focal_point = vec_add(ro, vec_scale(dir, t->focal_dist));
					ro = vec_add(ro, offset);
					dir = vec_norm(vec_sub(focal_point, ro));
				}
				t_hit first_hit;
				double depth = -1.0;
				if (trace(t->scene, ro, dir, &first_hit))
					depth = first_hit.t;
				t_color c = trace_ray(t->scene, ro, dir, t->max_depth);
				cr += c.r;
				cg += c.g;
				cb += c.b;
				if (depth >= 0)
				{
					int idx = y * t->width + x;
					if (t->depths[idx] < 0 || depth < t->depths[idx])
					{
						t->depths[idx] = depth;
						t->normals[idx] = first_hit.normal;
					}
				}
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

static double	tonemap_channel(double x, t_tonemap mode)
{
	if (mode == TM_REINHARD)
		return x / (1.0 + x);
	if (mode == TM_ACES)
	{
		double a = 2.51;
		double b = 0.03;
		double c = 2.43;
		double d = 0.59;
		double e = 0.14;
		return fmin(fmax((x * (a * x + b)) / (x * (c * x + d) + e), 0.0), 1.0);
	}
	return x;
}

static void	write_depth_ppm(const char *path, const double *depths, int width, int height)
{
	double maxd = 0.0;
	for (int i = 0; i < width * height; ++i)
		if (depths[i] > maxd)
			maxd = depths[i];
	FILE *f = fopen(path, "w");
	if (!f)
	{
		perror("fopen depth");
		return;
	}
	fprintf(f, "P3\n%d %d\n255\n", width, height);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			double d = depths[y * width + x];
			int val = 0;
			if (d > 0 && maxd > 0)
				val = clamp_i((int)((1.0 - fmin(d / maxd, 1.0)) * 255.0), 0, 255);
			fprintf(f, "%d %d %d ", val, val, val);
		}
		fprintf(f, "\n");
	}
	fclose(f);
}

static void	write_normals_ppm(const char *path, const t_vec3 *normals, int width, int height)
{
	FILE *f = fopen(path, "w");
	if (!f)
	{
		perror("fopen normal");
		return;
	}
	fprintf(f, "P3\n%d %d\n255\n", width, height);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			t_vec3 n = normals[y * width + x];
			int r = 0, g = 0, b = 0;
			if (n.x != 0 || n.y != 0 || n.z != 0)
			{
				r = clamp_i((int)((n.x * 0.5 + 0.5) * 255.0), 0, 255);
				g = clamp_i((int)((n.y * 0.5 + 0.5) * 255.0), 0, 255);
				b = clamp_i((int)((n.z * 0.5 + 0.5) * 255.0), 0, 255);
			}
			fprintf(f, "%d %d %d ", r, g, b);
		}
		fprintf(f, "\n");
	}
	fclose(f);
}

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma, int max_depth, const char *depth_path, const char *normal_path, t_tonemap tonemap)
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
	double *depths = calloc((size_t)width * (size_t)height, sizeof(double));
	t_vec3 *normals = calloc((size_t)width * (size_t)height, sizeof(t_vec3));
	if (!buffer || !depths || !normals)
	{
		perror("calloc");
		free(buffer);
		free(depths);
		free(normals);
		fclose(f);
		return 0;
	}
	for (int i = 0; i < width * height; ++i)
	{
		depths[i] = -1.0;
		normals[i] = (t_vec3){0, 0, 0};
	}
	int chunk = height / threads;
	for (int i = 0; i < threads; ++i)
	{
		tasks[i].scene = scene;
		tasks[i].buffer = buffer;
		tasks[i].depths = depths;
		tasks[i].normals = normals;
		tasks[i].width = width;
		tasks[i].height = height;
		tasks[i].samples = samples;
		tasks[i].y0 = i * chunk;
		tasks[i].y1 = (i == threads - 1) ? height : (i + 1) * chunk;
		tasks[i].max_depth = max_depth;
		tasks[i].forward = forward;
		tasks[i].right = right;
		tasks[i].up = up;
		tasks[i].aspect = aspect;
		tasks[i].fov_scale = fov_scale;
		tasks[i].aperture = scene->camera.aperture;
		tasks[i].focal_dist = scene->camera.focal_dist;
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
			double lr = tonemap_channel(c.r / 255.0, tonemap);
			double lg = tonemap_channel(c.g / 255.0, tonemap);
			double lb = tonemap_channel(c.b / 255.0, tonemap);
			fprintf(f, "%d %d %d ", apply_gamma((int)(lr * 255.0), gamma), apply_gamma((int)(lg * 255.0), gamma), apply_gamma((int)(lb * 255.0), gamma));
		}
		fprintf(f, "\n");
	}
	fclose(f);
	if (depth_path)
		write_depth_ppm(depth_path, depths, width, height);
	if (normal_path)
		write_normals_ppm(normal_path, normals, width, height);
	free(buffer);
	free(depths);
	free(normals);
	return 1;
}
