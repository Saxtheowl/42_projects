#include "render.h"

#define _GNU_SOURCE
#include <pthread.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef M_PI
# define M_PI 3.14159265358979323846
#endif

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
static uint32_t	g_base_seed = 1337u;

typedef struct s_hit
{
	double t;
	t_vec3 point;
	t_vec3 normal;
	int has_uv;
	double bu;
	double bv;
	t_vec3 geom_normal;
	t_material mat;
	const t_object *obj;
	int obj_index;
}	t_hit;

typedef struct s_bvh_node
{
	t_vec3 min;
	t_vec3 max;
	int left;
	int right;
	int start;
	int count;
}	t_bvh_node;

typedef struct s_render_ctx
{
	const t_scene	*scene;
	t_bvh_node		*bvh_nodes;
	int				bvh_nodes_count;
	int				*bvh_indices;
	int				bvh_indices_count;
	int				*plane_indices;
	int				plane_count;
	int				use_bvh;
}	t_render_ctx;

static t_color	background_color(const t_scene *scene, t_vec3 dir);
static t_vec3	random_hemisphere(t_vec3 n, uint32_t seed);

static int	trace(const t_render_ctx *ctx, t_vec3 ro, t_vec3 rd, t_hit *closest);

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
	hit->geom_normal = hit->normal;
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
	hit->geom_normal = hit->normal;
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
	hit->geom_normal = hit->normal;
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
		best.geom_normal = best.normal;
		best.mat = o->mat;
		best.obj = o;
	}
	t_hit caphit;
	if (intersect_cap(o->pos, ca, o->radius, ro, rd, &caphit, &o->mat) && (!hit_any || caphit.t < best.t))
	{
		best = caphit;
		best.geom_normal = best.normal;
		best.obj = o;
		hit_any = 1;
	}
	t_vec3 top_center = vec_add(o->pos, vec_scale(ca, o->height));
	if (intersect_cap(top_center, ca, o->radius, ro, rd, &caphit, &o->mat) && (!hit_any || caphit.t < best.t))
	{
		best = caphit;
		best.geom_normal = best.normal;
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
		best.geom_normal = n;
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
		best.geom_normal = best.normal;
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
	hit->geom_normal = hit->normal;
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
	hit->geom_normal = n;
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

static int	in_shadow(const t_render_ctx *ctx, t_vec3 point, t_vec3 light_dir, double max_dist)
{
	t_hit h;
	if (trace(ctx, vec_add(point, vec_scale(light_dir, 1e-3)), light_dir, &h))
		return h.t < max_dist;
	return 0;
}

static t_vec3	pick_tangent(t_vec3 n)
{
	t_vec3 ref = fabs(n.x) > 0.9 ? (t_vec3){0, 1, 0} : (t_vec3){1, 0, 0};
	return vec_norm(vec_cross(ref, n));
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

static void	srgb_to_linear(t_color *c);

static t_color	compute_albedo(const t_render_ctx *ctx, t_hit *hit)
{
	t_color base = hit->mat.color;
	double u = 0.0, v = 0.0;
	int has_uv = 0;
	if (hit->obj && hit->obj->type == OBJ_SPHERE)
	{
		t_vec3 p = vec_norm(vec_sub(hit->point, hit->obj->pos));
		u = (0.5 + atan2(p.z, p.x) / (2 * M_PI)) * hit->mat.uv_scale.u;
		v = (0.5 - asin(p.y) / M_PI) * hit->mat.uv_scale.v;
		has_uv = 1;
	}
	else if (hit->obj && hit->obj->type == OBJ_PLANE)
	{
		t_vec3 n = vec_norm(hit->obj->dir);
		t_vec3 tangent = pick_tangent(n);
		t_vec3 bitangent = vec_norm(vec_cross(n, tangent));
		t_vec3 rel = vec_sub(hit->point, hit->obj->pos);
		u = vec_dot(rel, tangent) * hit->mat.uv_scale.u;
		v = vec_dot(rel, bitangent) * hit->mat.uv_scale.v;
		has_uv = 1;
	}
	else if (hit->obj && hit->obj->type == OBJ_TRIANGLE && hit->has_uv)
	{
		double w = 1.0 - hit->bu - hit->bv;
		u = (hit->obj->uv0.u * w + hit->obj->uv1.u * hit->bu + hit->obj->uv2.u * hit->bv) * hit->mat.uv_scale.u;
		v = (hit->obj->uv0.v * w + hit->obj->uv1.v * hit->bu + hit->obj->uv2.v * hit->bv) * hit->mat.uv_scale.v;
		has_uv = 1;
	}
	if (hit->mat.texture && has_uv)
	{
		base = sample_texture(hit->mat.texture, u, v);
		if (ctx->scene->srgb_textures)
			srgb_to_linear(&base);
	}
	if (hit->obj && hit->obj->type == OBJ_PLANE && hit->obj->checker_enabled)
	{
		t_vec3 n = vec_norm(hit->obj->dir);
		t_vec3 tangent = pick_tangent(n);
		t_vec3 bitangent = vec_norm(vec_cross(n, tangent));
		t_vec3 rel = vec_sub(hit->point, hit->obj->pos);
		double cu = vec_dot(rel, tangent) / hit->obj->checker_size;
		double cv = vec_dot(rel, bitangent) / hit->obj->checker_size;
		long long iu = (long long)floor(cu);
		long long iv = (long long)floor(cv);
		int pattern = (iu + iv) & 1;
		if (pattern)
			base = hit->obj->checker_color;
	}
	return base;
}

static t_color	shade(const t_render_ctx *ctx, t_hit *hit, t_vec3 rd)
{
	double u = 0.0, v = 0.0;
	int has_uv = 0;
	int has_tbn = 0;
	t_vec3 tangent = {0, 0, 0};
	t_vec3 bitangent = {0, 0, 0};
	t_vec3 base_normal = hit->geom_normal;
	if (vec_len(base_normal) < 1e-9)
		base_normal = hit->normal;
	base_normal = vec_norm(base_normal);
	if (hit->obj && hit->obj->type == OBJ_SPHERE)
	{
		t_vec3 p = vec_norm(vec_sub(hit->point, hit->obj->pos));
		u = (0.5 + atan2(p.z, p.x) / (2 * M_PI)) * hit->mat.uv_scale.u;
		v = (0.5 - asin(p.y) / M_PI) * hit->mat.uv_scale.v;
		base_normal = p;
		tangent = pick_tangent(base_normal);
		bitangent = vec_norm(vec_cross(base_normal, tangent));
		has_uv = 1;
		has_tbn = 1;
	}
	else if (hit->obj && hit->obj->type == OBJ_PLANE)
	{
		t_vec3 n = vec_norm(hit->obj->dir);
		tangent = pick_tangent(n);
		bitangent = vec_norm(vec_cross(n, tangent));
		t_vec3 rel = vec_sub(hit->point, hit->obj->pos);
		u = vec_dot(rel, tangent) * hit->mat.uv_scale.u;
		v = vec_dot(rel, bitangent) * hit->mat.uv_scale.v;
		base_normal = n;
		has_uv = 1;
		has_tbn = 1;
	}
	else if (hit->obj && hit->obj->type == OBJ_TRIANGLE && hit->has_uv)
	{
		double w = 1.0 - hit->bu - hit->bv;
		u = (hit->obj->uv0.u * w + hit->obj->uv1.u * hit->bu + hit->obj->uv2.u * hit->bv) * hit->mat.uv_scale.u;
		v = (hit->obj->uv0.v * w + hit->obj->uv1.v * hit->bu + hit->obj->uv2.v * hit->bv) * hit->mat.uv_scale.v;
		has_uv = 1;
		/* tangent space */
		double du1 = hit->obj->uv1.u - hit->obj->uv0.u;
		double dv1 = hit->obj->uv1.v - hit->obj->uv0.v;
		double du2 = hit->obj->uv2.u - hit->obj->uv0.u;
		double dv2 = hit->obj->uv2.v - hit->obj->uv0.v;
		double denom = du1 * dv2 - dv1 * du2;
		if (fabs(denom) > 1e-8)
		{
			double inv = 1.0 / denom;
			t_vec3 e1 = vec_sub(hit->obj->v1, hit->obj->v0);
			t_vec3 e2 = vec_sub(hit->obj->v2, hit->obj->v0);
			tangent = vec_scale(vec_sub(vec_scale(e1, dv2), vec_scale(e2, dv1)), inv);
			bitangent = vec_scale(vec_sub(vec_scale(e2, du1), vec_scale(e1, du2)), inv);
			if (vec_len(tangent) > 1e-9 && vec_len(bitangent) > 1e-9)
			{
				tangent = vec_norm(tangent);
				bitangent = vec_norm(bitangent);
				has_tbn = 1;
			}
		}
	}
	if (hit->mat.texture && has_uv)
	{
		hit->mat.color = sample_texture(hit->mat.texture, u, v);
		if (ctx->scene->srgb_textures)
			srgb_to_linear(&hit->mat.color);
	}
	apply_checker(hit->obj, hit);

	/* normal mapping */
	hit->normal = base_normal;
	if (hit->mat.normal_map && has_uv)
	{
		if (!has_tbn)
		{
			tangent = pick_tangent(base_normal);
			bitangent = vec_norm(vec_cross(base_normal, tangent));
			has_tbn = 1;
		}
		t_color nm = sample_texture(hit->mat.normal_map, u, v);
		double nx = nm.r / 255.0 * 2.0 - 1.0;
		double ny = nm.g / 255.0 * 2.0 - 1.0;
		double nz = nm.b / 255.0 * 2.0 - 1.0;
		t_vec3 mapped = vec_add(vec_add(vec_scale(tangent, nx), vec_scale(bitangent, ny)), vec_scale(base_normal, nz));
		hit->normal = vec_norm(mapped);
	}

	double r = ctx->scene->ambient_intensity * hit->mat.color.r * ctx->scene->ambient_color.r / 255.0 / 255.0;
	double g = ctx->scene->ambient_intensity * hit->mat.color.g * ctx->scene->ambient_color.g / 255.0 / 255.0;
	double b = ctx->scene->ambient_intensity * hit->mat.color.b * ctx->scene->ambient_color.b / 255.0 / 255.0;
	/* env diffuse sampling */
	if (ctx->scene->env_tex && ctx->scene->env_samples > 0)
	{
		for (int s = 0; s < ctx->scene->env_samples; ++s)
		{
			uint32_t seed = (uint32_t)(fabs(hit->point.x * 961748927.0) + fabs(hit->point.y * 899809343.0) + fabs(hit->point.z * 961748941.0) + (uint32_t)s * 73856093u + g_base_seed);
			t_vec3 ldir = random_hemisphere(hit->normal, seed);
			double cosn = fmax(0.0, vec_dot(hit->normal, ldir));
			if (cosn <= 0.0)
				continue;
			t_color env = background_color(ctx->scene, ldir);
			double lr = env.r / 255.0 * ctx->scene->env_intensity;
			double lg = env.g / 255.0 * ctx->scene->env_intensity;
			double lb = env.b / 255.0 * ctx->scene->env_intensity;
			double scale = (hit->mat.kd * cosn) / (double)ctx->scene->env_samples;
			r += scale * lr * (hit->mat.color.r / 255.0);
			g += scale * lg * (hit->mat.color.g / 255.0);
			b += scale * lb * (hit->mat.color.b / 255.0);
		}
	}
	if (ctx->scene->ao_samples > 0 && ctx->scene->ao_radius > 1e-6)
	{
		int occ = 0;
		for (int s = 0; s < ctx->scene->ao_samples; ++s)
		{
			uint32_t seed = (uint32_t)(fabs(hit->point.x * 73856093.0) + fabs(hit->point.y * 19349663.0) + fabs(hit->point.z * 83492791.0) + (uint32_t)s * 2654435761u);
			t_vec3 dir = random_in_unit_sphere(seed);
			if (vec_dot(dir, hit->normal) < 0.0)
				dir = vec_scale(dir, -1.0);
			dir = vec_norm(dir);
			t_hit h;
			if (trace(ctx, vec_add(hit->point, vec_scale(hit->normal, 1e-3)), dir, &h) && h.t < ctx->scene->ao_radius)
				occ++;
		}
		double ao = 1.0 - (double)occ / (double)ctx->scene->ao_samples;
		if (ao < 0.0)
			ao = 0.0;
		r *= ao;
		g *= ao;
		b *= ao;
	}

	if (hit->mat.emission_strength > 1e-9)
	{
		r += hit->mat.emission_strength * (hit->mat.emission_color.r / 255.0);
		g += hit->mat.emission_strength * (hit->mat.emission_color.g / 255.0);
		b += hit->mat.emission_strength * (hit->mat.emission_color.b / 255.0);
	}

	for (size_t i = 0; i < ctx->scene->lights_count; ++i)
	{
		t_light *L = &ctx->scene->lights[i];
		int samples = (L->radius > 1e-6 && L->type != LIGHT_DIR) ? 4 : 1;
		for (int s = 0; s < samples; ++s)
		{
			t_vec3 lp = L->pos;
			t_vec3 ldir;
			double dist;
			if (L->type == LIGHT_DIR)
			{
				ldir = vec_scale(L->dir, -1.0);
				dist = 1e9;
				samples = (L->radius > 1e-6) ? 4 : 1;
				if (L->radius > 1e-6)
				{
					uint32_t seed = (uint32_t)(i * 73856093u + s * 19349663u + (uint32_t)(fabs(hit->point.x * 9973.0)) + g_base_seed);
					t_vec3 jitter = random_in_unit_sphere(seed);
					t_vec3 offset = vec_norm(vec_cross(ldir, (fabs(ldir.x) > 0.9) ? (t_vec3){0,1,0} : (t_vec3){1,0,0}));
					t_vec3 offset2 = vec_norm(vec_cross(ldir, offset));
					lp = vec_add(hit->point, vec_add(vec_scale(offset, jitter.x * L->radius), vec_scale(offset2, jitter.y * L->radius)));
					ldir = vec_norm(vec_scale(L->dir, -1.0));
				}
			}
			else if (L->radius > 1e-6)
			{
				uint32_t seed = (uint32_t)(i * 73856093u + s * 19349663u + (uint32_t)(fabs(hit->point.x * 9973.0)) + g_base_seed);
				t_vec3 jitter = random_in_unit_sphere(seed);
				lp = vec_add(lp, vec_scale(jitter, L->radius));
				ldir = vec_sub(lp, hit->point);
				dist = vec_len(ldir);
				ldir = vec_scale(ldir, 1.0 / dist);
			}
			else
			{
				ldir = vec_sub(lp, hit->point);
				dist = vec_len(ldir);
				ldir = vec_scale(ldir, 1.0 / dist);
			}
			if (L->type == LIGHT_SPOT)
			{
				double cos_theta = vec_dot(vec_scale(ldir, -1.0), L->dir);
				if (cos_theta < L->cutoff_cos)
					continue;
			}
			if (in_shadow(ctx, hit->point, ldir, dist))
				continue;
			double attenuation = (L->type == LIGHT_DIR) ? 1.0 : 1.0 / (1.0 + 0.09 * dist + 0.032 * dist * dist);
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
	if (scene->env_tex)
	{
		double u = 0.5 + atan2(dir.z, dir.x) / (2 * M_PI);
		double v = 0.5 - asin(dir.y) / M_PI;
		return sample_texture(scene->env_tex, u, v);
	}
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
	seed ^= g_base_seed;
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
	seed ^= g_base_seed;
	double u = hash_u32(seed);
	double v = hash_u32(seed * 1664525u + 1013904223u);
	double theta = 2.0 * M_PI * u;
	double cosphi = 1.0 - 2.0 * v;
	double sinphi = sqrt(fmax(0.0, 1.0 - cosphi * cosphi));
	double r = cbrt(hash_u32(seed * 747796405u + 2891336453u));
	return (t_vec3){r * sinphi * cos(theta), r * sinphi * sin(theta), r * cosphi};
}

static t_vec3	random_hemisphere(t_vec3 n, uint32_t seed)
{
	t_vec3 d = random_in_unit_sphere(seed);
	if (vec_dot(d, n) < 0.0)
		d = vec_scale(d, -1.0);
	return vec_norm(d);
}

t_color	sample_texture(const t_texture *tex, double u, double v)
{
	if (!tex || !tex->pixels || tex->width <= 0 || tex->height <= 0)
		return (t_color){0, 0, 0};
	u = u - floor(u);
	v = v - floor(v);
	double fx = u * tex->width - 0.5;
	double fy = v * tex->height - 0.5;
	int x0 = ((int)floor(fx) % tex->width + tex->width) % tex->width;
	int y0 = ((int)floor(fy) % tex->height + tex->height) % tex->height;
	int x1 = (x0 + 1) % tex->width;
	int y1 = (y0 + 1) % tex->height;
	double tx = fx - floor(fx);
	double ty = fy - floor(fy);
	t_color c00 = tex->pixels[y0 * tex->width + x0];
	t_color c10 = tex->pixels[y0 * tex->width + x1];
	t_color c01 = tex->pixels[y1 * tex->width + x0];
	t_color c11 = tex->pixels[y1 * tex->width + x1];
	t_color out;
	out.r = (int)((1 - ty) * ((1 - tx) * c00.r + tx * c10.r) + ty * ((1 - tx) * c01.r + tx * c11.r));
	out.g = (int)((1 - ty) * ((1 - tx) * c00.g + tx * c10.g) + ty * ((1 - tx) * c01.g + tx * c11.g));
	out.b = (int)((1 - ty) * ((1 - tx) * c00.b + tx * c10.b) + ty * ((1 - tx) * c01.b + tx * c11.b));
	return out;
}

static void	srgb_to_linear(t_color *c)
{
	double r = pow(c->r / 255.0, 2.2);
	double g = pow(c->g / 255.0, 2.2);
	double b = pow(c->b / 255.0, 2.2);
	c->r = clamp_i((int)(r * 255.0 + 0.5), 0, 255);
	c->g = clamp_i((int)(g * 255.0 + 0.5), 0, 255);
	c->b = clamp_i((int)(b * 255.0 + 0.5), 0, 255);
}

static int	aabb_hit(t_vec3 min, t_vec3 max, t_vec3 ro, t_vec3 rd, double tmax)
{
	double tmin = 0.0;
	for (int i = 0; i < 3; ++i)
	{
		double dir = (&rd.x)[i];
		if (fabs(dir) < 1e-12)
		{
			if ((&ro.x)[i] < (&min.x)[i] || (&ro.x)[i] > (&max.x)[i])
				return 0;
			continue;
		}
		double inv = 1.0 / dir;
		double t1 = ((&min.x)[i] - (&ro.x)[i]) * inv;
		double t2 = ((&max.x)[i] - (&ro.x)[i]) * inv;
		if (t1 > t2)
		{
			double tmp = t1;
			t1 = t2;
			t2 = tmp;
		}
		tmin = t1 > tmin ? t1 : tmin;
		tmax = t2 < tmax ? t2 : tmax;
		if (tmax <= tmin)
			return 0;
	}
	return 1;
}

static int	object_aabb(const t_object *o, t_vec3 *min, t_vec3 *max)
{
	if (o->type == OBJ_PLANE)
		return 0;
	if (o->type == OBJ_SPHERE)
	{
		*min = (t_vec3){o->pos.x - o->radius, o->pos.y - o->radius, o->pos.z - o->radius};
		*max = (t_vec3){o->pos.x + o->radius, o->pos.y + o->radius, o->pos.z + o->radius};
		return 1;
	}
	if (o->type == OBJ_BOX)
	{
		*min = (t_vec3){o->pos.x - o->size.x, o->pos.y - o->size.y, o->pos.z - o->size.z};
		*max = (t_vec3){o->pos.x + o->size.x, o->pos.y + o->size.y, o->pos.z + o->size.z};
		return 1;
	}
	if (o->type == OBJ_TRIANGLE)
	{
		*min = (t_vec3){
			fmin(o->v0.x, fmin(o->v1.x, o->v2.x)),
			fmin(o->v0.y, fmin(o->v1.y, o->v2.y)),
			fmin(o->v0.z, fmin(o->v1.z, o->v2.z))};
		*max = (t_vec3){
			fmax(o->v0.x, fmax(o->v1.x, o->v2.x)),
			fmax(o->v0.y, fmax(o->v1.y, o->v2.y)),
			fmax(o->v0.z, fmax(o->v1.z, o->v2.z))};
		return 1;
	}
	if (o->type == OBJ_CYLINDER || o->type == OBJ_CONE)
	{
		t_vec3 ca = vec_norm(o->dir);
		double radius = (o->type == OBJ_CYLINDER) ? o->radius : (o->height * tan(o->angle * M_PI / 180.0));
		t_vec3 p0 = o->pos;
		t_vec3 p1 = vec_add(o->pos, vec_scale(ca, o->height));
		*min = (t_vec3){fmin(p0.x, p1.x) - radius, fmin(p0.y, p1.y) - radius, fmin(p0.z, p1.z) - radius};
		*max = (t_vec3){fmax(p0.x, p1.x) + radius, fmax(p0.y, p1.y) + radius, fmax(p0.z, p1.z) + radius};
		return 1;
	}
	return 0;
}

static int	object_centroid(const t_object *o, t_vec3 *out)
{
	t_vec3 min, max;
	if (!object_aabb(o, &min, &max))
		return 0;
	*out = (t_vec3){(min.x + max.x) * 0.5, (min.y + max.y) * 0.5, (min.z + max.z) * 0.5};
	return 1;
}

static int	g_sort_axis = 0;
static const t_scene *g_sort_scene = NULL;

static int	cmp_indices(const void *a, const void *b)
{
	int ia = *(const int *)a;
	int ib = *(const int *)b;
	t_vec3 ca, cb;
	if (!object_centroid(&g_sort_scene->objects[ia], &ca))
		return 0;
	if (!object_centroid(&g_sort_scene->objects[ib], &cb))
		return 0;
	double va = (&ca.x)[g_sort_axis];
	double vb = (&cb.x)[g_sort_axis];
	return (va < vb) ? -1 : (va > vb);
}

static int	build_bvh(t_scene *scene, int *indices, int start, int count, t_bvh_node *nodes, int *node_count)
{
	int idx = (*node_count)++;
	t_bvh_node *n = &nodes[idx];
	t_vec3 min = {1e30, 1e30, 1e30};
	t_vec3 max = {-1e30, -1e30, -1e30};
	for (int i = start; i < start + count; ++i)
	{
		t_vec3 bmin, bmax;
		if (!object_aabb(&scene->objects[indices[i]], &bmin, &bmax))
			continue;
		min.x = fmin(min.x, bmin.x);
		min.y = fmin(min.y, bmin.y);
		min.z = fmin(min.z, bmin.z);
		max.x = fmax(max.x, bmax.x);
		max.y = fmax(max.y, bmax.y);
		max.z = fmax(max.z, bmax.z);
	}
	n->min = min;
	n->max = max;
	if (count <= 2)
	{
		n->start = start;
		n->count = count;
		n->left = n->right = -1;
		return idx;
	}
	t_vec3 extent = {max.x - min.x, max.y - min.y, max.z - min.z};
	if (extent.x >= extent.y && extent.x >= extent.z)
		g_sort_axis = 0;
	else if (extent.y >= extent.x && extent.y >= extent.z)
		g_sort_axis = 1;
	else
		g_sort_axis = 2;
	g_sort_scene = scene;
	qsort(indices + start, (size_t)count, sizeof(int), cmp_indices);
	int mid = start + count / 2;
	n->start = -1;
	n->count = 0;
	n->left = build_bvh(scene, indices, start, mid - start, nodes, node_count);
	n->right = build_bvh(scene, indices, mid, start + count - mid, nodes, node_count);
	return idx;
}

static int	trace(const t_render_ctx *ctx, t_vec3 ro, t_vec3 rd, t_hit *closest)
{
	int hit_any = 0;
	closest->t = 1e30;
	if (!ctx->use_bvh)
	{
		for (size_t i = 0; i < ctx->scene->objects_count; ++i)
		{
			t_hit h;
			memset(&h, 0, sizeof(h));
			int ok = 0;
			const t_object *o = &ctx->scene->objects[i];
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
			if (ok && h.t < closest->t)
			{
				hit_any = 1;
				*closest = h;
				closest->obj_index = (int)i;
			}
		}
		return hit_any;
	}
	/* BVH traversal */
	int stack[128];
	int sp = 0;
	if (ctx->bvh_nodes_count > 0)
		stack[sp++] = 0;
	while (sp > 0)
	{
		int ni = stack[--sp];
		t_bvh_node *n = &ctx->bvh_nodes[ni];
		if (!aabb_hit(n->min, n->max, ro, rd, closest->t))
			continue;
		if (n->left == -1 && n->right == -1)
		{
			for (int i = 0; i < n->count; ++i)
			{
				int obj_idx = ctx->bvh_indices[n->start + i];
				const t_object *o = &ctx->scene->objects[obj_idx];
				t_hit h;
				memset(&h, 0, sizeof(h));
				int ok = 0;
				if (o->type == OBJ_SPHERE)
					ok = intersect_sphere(o, ro, rd, &h);
				else if (o->type == OBJ_CYLINDER)
					ok = intersect_cylinder(o, ro, rd, &h);
				else if (o->type == OBJ_CONE)
					ok = intersect_cone(o, ro, rd, &h);
				else if (o->type == OBJ_BOX)
					ok = intersect_box(o, ro, rd, &h);
				else if (o->type == OBJ_TRIANGLE)
					ok = intersect_triangle(o, ro, rd, &h);
				if (ok && h.t < closest->t)
				{
					hit_any = 1;
					*closest = h;
					closest->obj_index = obj_idx;
				}
			}
		}
		else
		{
			if (n->left != -1)
				stack[sp++] = n->left;
			if (n->right != -1)
				stack[sp++] = n->right;
		}
	}
	/* Planes (non-bornés) en parcours linéaire */
	for (int i = 0; i < ctx->plane_count; ++i)
	{
		int idx = ctx->plane_indices[i];
		const t_object *o = &ctx->scene->objects[idx];
		t_hit h;
		memset(&h, 0, sizeof(h));
		if (intersect_plane(o, ro, rd, &h) && h.t < closest->t)
		{
			hit_any = 1;
			*closest = h;
			closest->obj_index = idx;
		}
	}
	return hit_any;
}

static t_color	trace_ray(const t_render_ctx *ctx, t_vec3 ro, t_vec3 rd, int depth)
{
	t_hit hit;
	if (!trace(ctx, ro, rd, &hit))
		return background_color(ctx->scene, rd);
	t_color local = shade(ctx, &hit, rd);
	if (ctx->scene->fog_enabled && ctx->scene->fog_density > 0.0)
	{
		double f = 1.0 - exp(-ctx->scene->fog_density * hit.t);
		f = f < 0.0 ? 0.0 : (f > 1.0 ? 1.0 : f);
		local.r = clamp_i((int)(local.r * (1.0 - f) + ctx->scene->fog_color.r * f), 0, 255);
		local.g = clamp_i((int)(local.g * (1.0 - f) + ctx->scene->fog_color.g * f), 0, 255);
		local.b = clamp_i((int)(local.b * (1.0 - f) + ctx->scene->fog_color.b * f), 0, 255);
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
	t_color refl_col = {0, 0, 0};
	int refl_samples = (hit.mat.roughness > 1e-6) ? ctx->scene->glossy_samples : 1;
	if (refl_samples < 1)
		refl_samples = 1;
	for (int s = 0; s < refl_samples; ++s)
	{
		t_vec3 refl_dir = reflect(vec_scale(rd, -1.0), hit.normal);
		if (hit.mat.roughness > 1e-6)
		{
			uint32_t seed = (uint32_t)(fabs(hit.point.x * 73856093.0) + fabs(hit.point.y * 19349663.0) + fabs(hit.point.z * 83492791.0) + (uint32_t)(depth * 2654435761u) + (uint32_t)s * 97u);
			t_vec3 jitter = random_in_unit_sphere(seed);
			refl_dir = vec_norm(vec_add(refl_dir, vec_scale(jitter, hit.mat.roughness)));
		}
		t_color c = trace_ray(ctx, vec_add(hit.point, vec_scale(hit.normal, 1e-3)), refl_dir, depth - 1);
		refl_col.r += c.r;
		refl_col.g += c.g;
		refl_col.b += c.b;
	}
	refl_col.r /= refl_samples;
	refl_col.g /= refl_samples;
	refl_col.b /= refl_samples;
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
			refr_col = trace_ray(ctx, vec_add(hit.point, vec_scale(refr_dir, 1e-3)), refr_dir, depth - 1);
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
	const t_render_ctx *ctx;
	t_color			*buffer;
	double			*depths;
	t_vec3			*normals;
	int				*ids;
	t_color			*albedos;
	t_vec3			*positions;
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
				t_vec3 ro = t->ctx->scene->camera.pos;
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
				if (trace(t->ctx, ro, dir, &first_hit))
					depth = first_hit.t;
				t_color c = trace_ray(t->ctx, ro, dir, t->max_depth);
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
						if (t->ids)
							t->ids[idx] = first_hit.obj_index;
						if (t->albedos)
							t->albedos[idx] = compute_albedo(t->ctx, &first_hit);
						if (t->positions)
							t->positions[idx] = first_hit.point;
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

static void	initialize_depth_normals(t_render_frame *frame)
{
	int total = frame->width * frame->height;
	for (int i = 0; i < total; ++i)
	{
		frame->depths[i] = -1.0;
		frame->normals[i] = (t_vec3){0, 0, 0};
		if (frame->ids)
			frame->ids[i] = -1;
		if (frame->albedos)
			frame->albedos[i] = (t_color){0, 0, 0};
		if (frame->positions)
			frame->positions[i] = (t_vec3){0, 0, 0};
	}
}

static int	build_bvh_indices(const t_scene *scene, int **bvh_indices, int *bvh_count, int **plane_indices, int *plane_count)
{
	if (!scene->enable_bvh || scene->objects_count == 0)
	{
		*bvh_indices = NULL;
		*plane_indices = NULL;
		*bvh_count = 0;
		*plane_count = 0;
		return 1;
	}
	*bvh_indices = malloc(scene->objects_count * sizeof(int));
	*plane_indices = malloc(scene->objects_count * sizeof(int));
	if (!*bvh_indices || !*plane_indices)
	{
		free(*bvh_indices);
		free(*plane_indices);
		return 0;
	}
	for (size_t i = 0; i < scene->objects_count; ++i)
	{
		t_vec3 dummy_min;
		t_vec3 dummy_max;
		if (scene->objects[i].type == OBJ_PLANE || !object_aabb(&scene->objects[i], &dummy_min, &dummy_max))
			(*plane_indices)[(*plane_count)++] = (int)i;
		else
			(*bvh_indices)[(*bvh_count)++] = (int)i;
	}
	return 1;
}

int	render_frame(t_render_frame *frame, const t_scene *scene, int width, int height, int samples, int threads, int max_depth, int capture_ids, int capture_albedo, int capture_position)
{
	if (!frame || !scene || width <= 0 || height <= 0 || samples <= 0 || max_depth < 0)
		return 0;
	frame->width = width;
	frame->height = height;
	g_base_seed = scene->base_seed;

	t_vec3 forward = vec_norm(scene->camera.dir);
	t_vec3 up = scene->camera.has_up ? scene->camera.up : (t_vec3){0, 1, 0};
	if (fabs(vec_dot(up, forward)) > 0.99)
		up = (t_vec3){1, 0, 0};
	t_vec3 right = vec_norm((t_vec3){forward.y * up.z - forward.z * up.y,
									 forward.z * up.x - forward.x * up.z,
									 forward.x * up.y - forward.y * up.x});
	if (vec_len(right) < 1e-6)
		right = (t_vec3){1, 0, 0};
	up = vec_norm((t_vec3){right.y * forward.z - right.z * forward.y,
						   right.z * forward.x - right.x * forward.z,
						   right.x * forward.y - right.y * forward.x});
	double aspect = (double)width / (double)height;
	double fov_scale = tan(scene->camera.fov * 0.5 * M_PI / 180.0);
	int render_threads = threads;
	if (render_threads <= 0)
		render_threads = 4;
	if (render_threads > height)
		render_threads = height;
	if (render_threads < 1)
		render_threads = 1;

	int *bvh_indices = NULL;
	int bvh_count = 0;
	int *plane_indices = NULL;
	int plane_count = 0;
	if (!build_bvh_indices(scene, &bvh_indices, &bvh_count, &plane_indices, &plane_count))
		return 0;

	t_bvh_node *nodes = NULL;
	int nodes_count = 0;
	if (bvh_count > 0)
	{
		nodes = malloc(sizeof(t_bvh_node) * (size_t)(2 * bvh_count));
		if (!nodes)
		{
			free(bvh_indices);
			free(plane_indices);
			return 0;
		}
		build_bvh((t_scene *)scene, bvh_indices, 0, bvh_count, nodes, &nodes_count);
	}

	size_t total_pixels = (size_t)width * (size_t)height;
	frame->colors = calloc(total_pixels, sizeof(t_color));
	frame->depths = calloc(total_pixels, sizeof(double));
	frame->normals = calloc(total_pixels, sizeof(t_vec3));
	frame->ids = capture_ids ? calloc(total_pixels, sizeof(int)) : NULL;
	frame->albedos = capture_albedo ? calloc(total_pixels, sizeof(t_color)) : NULL;
	frame->positions = capture_position ? calloc(total_pixels, sizeof(t_vec3)) : NULL;
	if (!frame->colors || !frame->depths || !frame->normals ||
		(capture_ids && !frame->ids) ||
		(capture_albedo && !frame->albedos) ||
		(capture_position && !frame->positions))
	{
		free_render_frame(frame);
		free(bvh_indices);
		free(plane_indices);
		free(nodes);
		return 0;
	}

	initialize_depth_normals(frame);

	t_render_ctx ctx = {
		.scene = scene,
		.bvh_nodes = nodes,
		.bvh_nodes_count = nodes_count,
		.bvh_indices = bvh_indices,
		.bvh_indices_count = bvh_count,
		.plane_indices = plane_indices,
		.plane_count = plane_count,
		.use_bvh = scene->enable_bvh && bvh_count > 0};

	t_render_task tasks[render_threads];
	pthread_t	th[render_threads];
	int chunk = height / render_threads;
	for (int i = 0; i < render_threads; ++i)
	{
		tasks[i].ctx = &ctx;
		tasks[i].buffer = frame->colors;
		tasks[i].depths = frame->depths;
		tasks[i].normals = frame->normals;
		tasks[i].ids = frame->ids;
		tasks[i].albedos = frame->albedos;
		tasks[i].positions = frame->positions;
		tasks[i].width = width;
		tasks[i].height = height;
		tasks[i].samples = samples;
		tasks[i].y0 = i * chunk;
		tasks[i].y1 = (i == render_threads - 1) ? height : (i + 1) * chunk;
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

	for (int i = 0; i < render_threads; ++i)
		pthread_join(th[i], NULL);

	free(bvh_indices);
	free(plane_indices);
	free(nodes);
	return 1;
}

void	free_render_frame(t_render_frame *frame)
{
	if (!frame)
		return;
	free(frame->colors);
	free(frame->depths);
	free(frame->normals);
	free(frame->ids);
	free(frame->albedos);
	free(frame->positions);
	frame->colors = NULL;
	frame->depths = NULL;
	frame->normals = NULL;
	frame->ids = NULL;
	frame->albedos = NULL;
	frame->positions = NULL;
	frame->width = 0;
	frame->height = 0;
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

static void	write_depth_ppm(const char *path, const double *depths, int width, int height, int binary)
{
	double maxd = 0.0;
	for (int i = 0; i < width * height; ++i)
		if (depths[i] > maxd)
			maxd = depths[i];
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen depth");
		return;
	}
	if (binary)
	{
		fprintf(f, "P6\n%d %d\n255\n", width, height);
		for (int y = 0; y < height; ++y)
		{
			for (int x = 0; x < width; ++x)
			{
				double d = depths[y * width + x];
				int val = 0;
				if (d > 0 && maxd > 0)
					val = clamp_i((int)((1.0 - fmin(d / maxd, 1.0)) * 255.0), 0, 255);
				unsigned char px[3] = {(unsigned char)val, (unsigned char)val, (unsigned char)val};
				fwrite(px, 1, 3, f);
			}
		}
	}
	else
	{
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
	}
	fclose(f);
}

static void	write_normals_ppm(const char *path, const t_vec3 *normals, int width, int height, int binary)
{
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen normal");
		return;
	}
	if (binary)
		fprintf(f, "P6\n%d %d\n255\n", width, height);
	else
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
			if (binary)
			{
				unsigned char px[3] = {(unsigned char)r, (unsigned char)g, (unsigned char)b};
				fwrite(px, 1, 3, f);
			}
			else
				fprintf(f, "%d %d %d ", r, g, b);
		}
		if (!binary)
			fprintf(f, "\n");
	}
	fclose(f);
}

static t_color	hash_id_color(int id)
{
	uint32_t x = (uint32_t)(id * 2654435761u);
	x ^= x >> 17;
	x *= 0xed5ad4bbU;
	x ^= x >> 11;
	x *= 0xac4c1b51U;
	x ^= x >> 15;
	x *= 0x31848babU;
	return (t_color){(int)((x & 0xFF0000) >> 16), (int)((x & 0x00FF00) >> 8), (int)(x & 0x0000FF)};
}

static void	write_id_ppm(const char *path, const int *ids, int width, int height, int binary)
{
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen id");
		return;
	}
	if (binary)
		fprintf(f, "P6\n%d %d\n255\n", width, height);
	else
		fprintf(f, "P3\n%d %d\n255\n", width, height);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			int id = ids[y * width + x];
			t_color c = {0, 0, 0};
			if (id >= 0)
				c = hash_id_color(id + 1); /* +1 to avoid noir total */
			if (binary)
			{
				unsigned char px[3] = {(unsigned char)c.r, (unsigned char)c.g, (unsigned char)c.b};
				fwrite(px, 1, 3, f);
			}
			else
				fprintf(f, "%d %d %d ", c.r, c.g, c.b);
		}
		if (!binary)
			fprintf(f, "\n");
	}
	fclose(f);
}

static void	write_albedo_ppm(const char *path, const t_color *colors, int width, int height, int binary)
{
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen albedo");
		return;
	}
	if (binary)
		fprintf(f, "P6\n%d %d\n255\n", width, height);
	else
		fprintf(f, "P3\n%d %d\n255\n", width, height);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			t_color c = colors[y * width + x];
			if (binary)
			{
				unsigned char px[3] = {(unsigned char)c.r, (unsigned char)c.g, (unsigned char)c.b};
				fwrite(px, 1, 3, f);
			}
			else
				fprintf(f, "%d %d %d ", c.r, c.g, c.b);
		}
		if (!binary)
			fprintf(f, "\n");
	}
	fclose(f);
}

static void	write_position_ppm(const char *path, const t_vec3 *pos, int width, int height, double range, int binary)
{
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen position");
		return;
	}
	if (binary)
		fprintf(f, "P6\n%d %d\n255\n", width, height);
	else
		fprintf(f, "P3\n%d %d\n255\n", width, height);
	for (int y = 0; y < height; ++y)
	{
		for (int x = 0; x < width; ++x)
		{
			t_vec3 p = pos[y * width + x];
			int r = clamp_i((int)(((p.x + range) / (2 * range)) * 255.0), 0, 255);
			int g = clamp_i((int)(((p.y + range) / (2 * range)) * 255.0), 0, 255);
			int b = clamp_i((int)(((p.z + range) / (2 * range)) * 255.0), 0, 255);
			if (binary)
			{
				unsigned char px[3] = {(unsigned char)r, (unsigned char)g, (unsigned char)b};
				fwrite(px, 1, 3, f);
			}
			else
				fprintf(f, "%d %d %d ", r, g, b);
		}
		if (!binary)
			fprintf(f, "\n");
	}
	fclose(f);
}

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma, int max_depth, const char *depth_path, const char *normal_path, const char *id_path, const char *albedo_path, const char *position_path, t_tonemap tonemap, int binary, int binary_buffers, double exposure, double *avg_luminance, double *max_luminance, double *min_luminance, double *stddev_luminance, t_render_frame **out_frame)
{
	t_render_frame frame = {0};
	if (!render_frame(&frame, scene, width, height, samples, threads, max_depth, id_path != NULL, albedo_path != NULL, position_path != NULL))
		return 0;
	FILE *f = fopen(path, binary ? "wb" : "w");
	if (!f)
	{
		perror("fopen");
		free_render_frame(&frame);
		return 0;
	}
	if (binary)
		fprintf(f, "P6\n%d %d\n255\n", width, height);
	else
		fprintf(f, "P3\n%d %d\n255\n", width, height);
	t_color *buffer = frame.colors;
	if (binary)
	{
		unsigned char *row = malloc((size_t)width * 3);
		if (!row)
		{
			perror("malloc");
			fclose(f);
			free_render_frame(&frame);
			return 0;
		}
		for (int y = 0; y < height; ++y)
		{
			for (int x = 0; x < width; ++x)
			{
				t_color c = buffer[y * width + x];
				double lr = (c.r / 255.0) * exposure;
				double lg = (c.g / 255.0) * exposure;
				double lb = (c.b / 255.0) * exposure;
				if (scene->clamp_value > 0.0)
				{
					if (lr > scene->clamp_value)
						lr = scene->clamp_value;
					if (lg > scene->clamp_value)
						lg = scene->clamp_value;
					if (lb > scene->clamp_value)
						lb = scene->clamp_value;
				}
				lr = tonemap_channel(lr, tonemap);
				lg = tonemap_channel(lg, tonemap);
				lb = tonemap_channel(lb, tonemap);
				row[x * 3 + 0] = (unsigned char)apply_gamma((int)(lr * 255.0), gamma);
				row[x * 3 + 1] = (unsigned char)apply_gamma((int)(lg * 255.0), gamma);
				row[x * 3 + 2] = (unsigned char)apply_gamma((int)(lb * 255.0), gamma);
			}
			fwrite(row, 1, (size_t)width * 3, f);
		}
		free(row);
	}
	else
	{
		for (int y = 0; y < height; ++y)
		{
			for (int x = 0; x < width; ++x)
			{
				t_color c = buffer[y * width + x];
				double lr = (c.r / 255.0) * exposure;
				double lg = (c.g / 255.0) * exposure;
				double lb = (c.b / 255.0) * exposure;
				if (scene->clamp_value > 0.0)
				{
					if (lr > scene->clamp_value)
						lr = scene->clamp_value;
					if (lg > scene->clamp_value)
						lg = scene->clamp_value;
					if (lb > scene->clamp_value)
						lb = scene->clamp_value;
				}
				lr = tonemap_channel(lr, tonemap);
				lg = tonemap_channel(lg, tonemap);
				lb = tonemap_channel(lb, tonemap);
				fprintf(f, "%d %d %d ", apply_gamma((int)(lr * 255.0), gamma), apply_gamma((int)(lg * 255.0), gamma), apply_gamma((int)(lb * 255.0), gamma));
			}
			fprintf(f, "\n");
		}
	}
	fclose(f);
	if (depth_path)
		write_depth_ppm(depth_path, frame.depths, width, height, binary_buffers);
	if (normal_path)
		write_normals_ppm(normal_path, frame.normals, width, height, binary_buffers);
	if (id_path && frame.ids)
		write_id_ppm(id_path, frame.ids, width, height, binary_buffers);
	if (albedo_path && frame.albedos)
		write_albedo_ppm(albedo_path, frame.albedos, width, height, binary_buffers);
	if (position_path && frame.positions)
		write_position_ppm(position_path, frame.positions, width, height, scene->position_range, binary_buffers);
	double lum_sum = 0.0;
	double lum_sq = 0.0;
	double lum_max = 0.0;
	double lum_min = 0.0;
	int min_set = 0;
	for (int i = 0; i < width * height; ++i)
	{
		double lum = (0.2126 * buffer[i].r + 0.7152 * buffer[i].g + 0.0722 * buffer[i].b) / 255.0;
		lum_sum += lum;
		lum_sq += lum * lum;
		if (lum > lum_max)
			lum_max = lum;
		if (!min_set || lum < lum_min)
		{
			lum_min = lum;
			min_set = 1;
		}
	}
	double lum_avg = (width > 0 && height > 0) ? (lum_sum / (width * height)) : 0.0;
	double lum_std = 0.0;
	if (width > 0 && height > 0)
	{
		double mean_sq = lum_sq / (width * height);
		lum_std = mean_sq - lum_avg * lum_avg;
		if (lum_std < 0.0)
			lum_std = 0.0;
		lum_std = sqrt(lum_std);
	}
	if (avg_luminance)
		*avg_luminance = lum_avg;
	if (max_luminance)
		*max_luminance = lum_max;
	if (min_luminance)
		*min_luminance = (min_set ? lum_min : 0.0);
	if (stddev_luminance)
		*stddev_luminance = lum_std;
	int keep_frame = (out_frame != NULL);
	t_render_frame *owned_frame = NULL;
	if (keep_frame && out_frame)
	{
		owned_frame = malloc(sizeof(t_render_frame));
		if (!owned_frame)
		{
			free_render_frame(&frame);
			return 0;
		}
		*owned_frame = frame;
		*out_frame = owned_frame;
	}
	else
	{
		free_render_frame(&frame);
	}
	return 1;
}
