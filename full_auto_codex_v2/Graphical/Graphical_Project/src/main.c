#include "parser.h"
#include "render.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void	usage(const char *prog)
{
	printf("Usage: %s [scene.rt] [--out output.ppm] [--size WxH] [--samples N] [--threads N] [--gamma G] [--maxdepth D] [--depth depth.ppm] [--normal normal.ppm] [--tonemap none|reinhard|aces]\n", prog);
	printf("Defaults: scene assets/scenes/sample.rt, output: output.ppm, size: 800x600, samples: 1, threads: auto (4 ou hauteur), gamma: 2.2, maxdepth: 2, tonemap: none\n");
}

static void	print_scene(const t_scene *s)
{
	printf("Camera: (%.2f %.2f %.2f) dir(%.2f %.2f %.2f) fov %.1f\n",
		   s->camera.pos.x, s->camera.pos.y, s->camera.pos.z,
		   s->camera.dir.x, s->camera.dir.y, s->camera.dir.z, s->camera.fov);
	printf("Ambient: %.2f rgb(%d %d %d)\n", s->ambient_intensity,
		   s->ambient_color.r, s->ambient_color.g, s->ambient_color.b);
	printf("Lights: %zu, Objects: %zu\n", s->lights_count, s->objects_count);
	for (size_t i = 0; i < s->lights_count; ++i)
		printf("  Light %zu at (%.2f %.2f %.2f) I=%.2f rgb(%d %d %d)\n", i,
			   s->lights[i].pos.x, s->lights[i].pos.y, s->lights[i].pos.z,
			   s->lights[i].intensity, s->lights[i].color.r, s->lights[i].color.g, s->lights[i].color.b);
	for (size_t i = 0; i < s->objects_count; ++i)
	{
		const t_object *o = &s->objects[i];
		const char *type = (o->type == OBJ_SPHERE) ? "sphere" : (o->type == OBJ_PLANE) ? "plane" : (o->type == OBJ_CYLINDER) ? "cylinder" : (o->type == OBJ_CONE) ? "cone" : "box";
		printf("  Obj %zu %-8s pos(%.2f %.2f %.2f)", i, type, o->pos.x, o->pos.y, o->pos.z);
		if (o->type != OBJ_SPHERE)
			printf(" dir(%.2f %.2f %.2f)", o->dir.x, o->dir.y, o->dir.z);
		if (o->type == OBJ_SPHERE || o->type == OBJ_CYLINDER)
			printf(" radius=%.2f", o->radius);
		if (o->type == OBJ_BOX)
			printf(" size(%.2f %.2f %.2f)", o->size.x, o->size.y, o->size.z);
		if (o->type == OBJ_CYLINDER || o->type == OBJ_CONE)
			printf(" height=%.2f", o->height);
		if (o->type == OBJ_CONE)
			printf(" angle=%.2f", o->angle);
		printf(" color(%d %d %d) kd=%.2f ks=%.2f shin=%d refl=%.2f",
			   o->mat.color.r, o->mat.color.g, o->mat.color.b, o->mat.kd, o->mat.ks, o->mat.shininess, o->mat.reflect);
		if (o->checker_enabled)
			printf(" checker(size=%.2f color %d %d %d)", o->checker_size, o->checker_color.r, o->checker_color.g, o->checker_color.b);
		printf("\n");
	}
}

int	main(int argc, char **argv)
{
	const char *path = "assets/scenes/sample.rt";
	const char *out = "output.ppm";
	const char *depth_out = NULL;
	const char *normal_out = NULL;
	int width = 800, height = 600, samples = 1, threads = 0, max_depth = 2;
	double gamma = 2.2;
	t_tonemap tonemap = TM_NONE;
	for (int i = 1; i < argc; ++i)
	{
		if (argv[i][0] != '-')
			path = argv[i];
		else if (strcmp(argv[i], "--out") == 0 && i + 1 < argc)
			out = argv[++i];
		else if (strcmp(argv[i], "--size") == 0 && i + 1 < argc)
		{
			if (sscanf(argv[++i], "%dx%d", &width, &height) != 2)
			{
				fprintf(stderr, "Invalid size, expected WxH\n");
				return EXIT_FAILURE;
			}
		}
		else if (strcmp(argv[i], "--samples") == 0 && i + 1 < argc)
			samples = atoi(argv[++i]);
		else if (strcmp(argv[i], "--threads") == 0 && i + 1 < argc)
			threads = atoi(argv[++i]);
		else if (strcmp(argv[i], "--gamma") == 0 && i + 1 < argc)
			gamma = atof(argv[++i]);
		else if (strcmp(argv[i], "--maxdepth") == 0 && i + 1 < argc)
			max_depth = atoi(argv[++i]);
		else if (strcmp(argv[i], "--depth") == 0 && i + 1 < argc)
			depth_out = argv[++i];
		else if (strcmp(argv[i], "--normal") == 0 && i + 1 < argc)
			normal_out = argv[++i];
		else if (strcmp(argv[i], "--tonemap") == 0 && i + 1 < argc)
		{
			const char *t = argv[++i];
			if (strcmp(t, "reinhard") == 0)
				tonemap = TM_REINHARD;
			else if (strcmp(t, "aces") == 0)
				tonemap = TM_ACES;
			else
				tonemap = TM_NONE;
		}
		else
		{
			usage(argv[0]);
			return EXIT_FAILURE;
		}
	}
	t_scene scene;

	if (!parse_scene(path, &scene))
	{
		fprintf(stderr, "Failed to parse scene: %s\n", path);
		return EXIT_FAILURE;
	}
	printf("Scene loaded: %s\n", path);
	print_scene(&scene);
	if (samples < 1)
		samples = 1;
	if (threads < 0)
		threads = 0;
	if (max_depth < 0)
		max_depth = 0;
	if (gamma <= 0.0)
		gamma = 2.2;
	if (render_ppm(&scene, out, width, height, samples, threads, gamma, max_depth, depth_out, normal_out, tonemap))
	{
		printf("Rendered to %s (%dx%d, %d sample%s, %s threads, gamma=%.2f, maxdepth=%d).\n",
			   out, width, height, samples, (samples > 1 ? "s" : ""), (threads > 0 ? "custom" : "auto"), gamma, max_depth);
		if (depth_out)
			printf("Depth map written to %s.\n", depth_out);
		if (normal_out)
			printf("Normal map written to %s.\n", normal_out);
		if (tonemap == TM_REINHARD)
			printf("Tonemap: Reinhard.\n");
		else if (tonemap == TM_ACES)
			printf("Tonemap: ACES.\n");
		printf("Intégrer MLX pour l'affichage temps réel.\n");
	}
	free_scene(&scene);
	return EXIT_SUCCESS;
}
