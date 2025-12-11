#include "parser.h"
#include "render.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <ctype.h>

#define MAX_STATS_ENV 8
#define MAX_STATS_TAGS 8
#include "mlx_bridge.h"

static void	usage(const char *prog)
{
	printf("Usage: %s [scene.rt] [--out output.ppm] [--size WxH] [--samples N] [--threads N] [--gamma G] [--maxdepth D] [--depth depth.ppm] [--normal normal.ppm] [--id id.ppm] [--albedo albedo.ppm] [--position pos.ppm] [--pos-range R] [--tonemap none|reinhard|aces] [--sky r1 g1 b1 r0 g0 b0] [--binary] [--bin-buffers] [--stats stats.txt] [--stats-json stats.json|-] [--stats-append] [--stats-camera] [--stats-csv stats.csv|-] [--stats-csv-append] [--stats-console] [--stats-console-json] [--stats-console-stdout] [--stats-comment text] [--stats-comment-env VAR] [--stats-tag key=value] [--stats-env VAR] [--stats-ms] [--stats-fps] [--stats-group name] [--env-intensity X] [--no-bvh] [--ao radius samples] [--srgb-textures] [--exposure X] [--glossy-samples N] [--env-samples N] [--seed S] [--clamp C] [--mlx] [--mlx-snapshot path] [--mlx-depth path] [--mlx-overlay text]\n", prog);
	printf("Defaults: scene assets/scenes/sample.rt, output: output.ppm, size: 800x600, samples: 1, threads: auto (4 ou hauteur), gamma: 2.2, maxdepth: 2, tonemap: none, exposure: 1.0, glossy-samples: 1, env-samples: 0, pos-range: 10.0, seed: 1337, clamp: off, bin-buffers: off, stats append: off, env-intensity: 1.0\n");
	printf("Options texture/mat: reflect transparency ior roughness emission_strength er eg eb [texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]]\n");
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

static void	json_escape(FILE *f, const char *s)
{
	if (!s)
		return;
	while (*s)
	{
		if (*s == '"' || *s == '\\')
		{
			fputc('\\', f);
			fputc(*s, f);
		}
		else if (*s == '\n')
			fputs("\\n", f);
		else if (*s == '\r')
			fputs("\\r", f);
		else
			fputc(*s, f);
		++s;
	}
}

static void	csv_escape(FILE *f, const char *s)
{
	fputc('"', f);
	if (s)
	{
		while (*s)
		{
			if (*s == '"')
				fputs("\"\"", f);
			else if (*s == '\n' || *s == '\r')
				fputs(" ", f);
			else
				fputc(*s, f);
			++s;
		}
	}
	fputc('"', f);
}

static void	sanitize_comment(char *dst, size_t size, const char *src)
{
	size_t i = 0;
	if (!size)
		return;
	if (!src)
	{
		dst[0] = '\0';
		return;
	}
	while (*src && i + 1 < size)
	{
		char c = *src++;
		if (c == '\n' || c == '\r')
			dst[i++] = ' ';
		else
			dst[i++] = c;
	}
	dst[i] = '\0';
}

static void	build_env_summary(char *dst, size_t size, const char **vars, int count)
{
	size_t i = 0;
	if (!size)
		return;
	dst[0] = '\0';
	for (int idx = 0; idx < count; ++idx)
	{
		const char *name = vars[idx];
		const char *value = getenv(name);
		if (!value)
			value = "(unset)";
		if (i + 1 >= size)
			break;
		if (idx > 0)
		{
			dst[i++] = ';';
			if (i >= size)
				break;
		}
		while (*name && i + 1 < size)
			dst[i++] = *name++;
		if (i + 1 >= size)
			break;
		dst[i++] = '=';
		if (i >= size)
			break;
		const char *v = value;
		while (*v && i + 1 < size)
			dst[i++] = *v++;
	}
	if (i < size)
		dst[i] = '\0';
	else
		dst[size - 1] = '\0';
}

static void	build_tag_summary(char *dst, size_t size, const char **tags, int count)
{
	size_t i = 0;
	if (!size)
		return;
	dst[0] = '\0';
	for (int idx = 0; idx < count; ++idx)
	{
		const char *tag = tags[idx];
		if (!tag)
			continue;
		if (i + 1 >= size)
			break;
		if (idx > 0)
		{
			dst[i++] = ';';
			if (i >= size)
				break;
		}
		const char *c = tag;
		while (*c && i + 1 < size)
			dst[i++] = *c++;
	}
	if (i < size)
		dst[i] = '\0';
	else
		dst[size - 1] = '\0';
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
	int sky_set = 0;
	int binary = 0;
	int binary_buffers = 0;
	int use_bvh = 1;
	int ao_samples = 0;
	double ao_radius = 0.0;
	int srgb_textures = 0;
	double exposure = 1.0;
	int glossy_samples = 1;
	const char *id_out = NULL;
	const char *albedo_out = NULL;
	const char *position_out = NULL;
	int env_samples = 0;
	uint32_t base_seed = 1337u;
	double pos_range = 10.0;
	double clamp_value = 0.0;
	t_color sky_top = {135, 206, 250};
	t_color sky_bottom = {30, 30, 40};
	const char *stats_out = NULL;
	int stats_append = 0;
	int stats_camera = 0;
	const char *stats_json = NULL;
	int stats_json_stdout = 0;
	const char *stats_csv = NULL;
	int stats_csv_append = 0;
	int stats_csv_stdout = 0;
	int stats_console = 0;
	int stats_console_json = 0;
	int stats_console_stdout = 0;
	const char *stats_comment = NULL;
	const char *stats_comment_env = NULL;
	const char *stats_env[MAX_STATS_ENV];
	int stats_env_count = 0;
	const char *stats_tags[MAX_STATS_TAGS];
	int stats_tag_count = 0;
	int stats_ms = 0;
	int stats_fps = 0;
	const char *stats_group = NULL;
	double env_intensity = 1.0;
	int use_mlx = 0;
	const char *mlx_overlay_text = NULL;
	const char *mlx_snapshot_path = "mlx_snapshot.ppm";
	const char *mlx_depth_path = "mlx_depth.ppm";
	const char *mlx_auto_snapshot = NULL;
	const char *mlx_auto_depth = NULL;
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
		else if (strcmp(argv[i], "--id") == 0 && i + 1 < argc)
			id_out = argv[++i];
		else if (strcmp(argv[i], "--albedo") == 0 && i + 1 < argc)
			albedo_out = argv[++i];
		else if (strcmp(argv[i], "--position") == 0 && i + 1 < argc)
			position_out = argv[++i];
		else if (strcmp(argv[i], "--pos-range") == 0 && i + 1 < argc)
		{
			pos_range = atof(argv[++i]);
			if (pos_range <= 0.0)
				pos_range = 10.0;
		}
		else if (strcmp(argv[i], "--seed") == 0 && i + 1 < argc)
			base_seed = (uint32_t)strtoul(argv[++i], NULL, 10);
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
		else if (strcmp(argv[i], "--binary") == 0)
			binary = 1;
		else if (strcmp(argv[i], "--bin-buffers") == 0)
			binary_buffers = 1;
		else if (strcmp(argv[i], "--stats") == 0 && i + 1 < argc)
			stats_out = argv[++i];
		else if (strcmp(argv[i], "--stats-append") == 0)
			stats_append = 1;
		else if (strcmp(argv[i], "--stats-camera") == 0)
			stats_camera = 1;
		else if (strcmp(argv[i], "--stats-json") == 0 && i + 1 < argc)
			stats_json = argv[++i];
		else if (strcmp(argv[i], "--stats-csv") == 0 && i + 1 < argc)
		{
			stats_csv = argv[++i];
			stats_csv_stdout = (stats_csv[0] == '-' && stats_csv[1] == '\0');
		}
		else if (strcmp(argv[i], "--stats-csv-append") == 0)
			stats_csv_append = 1;
		else if (strcmp(argv[i], "--stats-console") == 0)
			stats_console = 1;
		else if (strcmp(argv[i], "--stats-console-json") == 0)
			stats_console_json = 1;
		else if (strcmp(argv[i], "--stats-console-stdout") == 0)
			stats_console_stdout = 1;
		else if (strcmp(argv[i], "--stats-comment") == 0 && i + 1 < argc)
			stats_comment = argv[++i];
		else if (strcmp(argv[i], "--stats-tag") == 0 && i + 1 < argc && stats_tag_count < MAX_STATS_TAGS)
			stats_tags[stats_tag_count++] = argv[++i];
		else if (strcmp(argv[i], "--stats-env") == 0 && i + 1 < argc && stats_env_count < MAX_STATS_ENV)
			stats_env[stats_env_count++] = argv[++i];
		else if (strcmp(argv[i], "--stats-ms") == 0)
			stats_ms = 1;
		else if (strcmp(argv[i], "--stats-comment-env") == 0 && i + 1 < argc)
			stats_comment_env = argv[++i];
		else if (strcmp(argv[i], "--stats-group") == 0 && i + 1 < argc)
			stats_group = argv[++i];
		else if (strcmp(argv[i], "--stats-fps") == 0)
			stats_fps = 1;
		else if (strcmp(argv[i], "--mlx") == 0)
			use_mlx = 1;
		else if (strcmp(argv[i], "--mlx-snapshot") == 0 && i + 1 < argc)
			mlx_snapshot_path = argv[++i];
		else if (strcmp(argv[i], "--mlx-depth") == 0 && i + 1 < argc)
			mlx_depth_path = argv[++i];
		else if (strcmp(argv[i], "--mlx-overlay") == 0 && i + 1 < argc)
			mlx_overlay_text = argv[++i];
		else if (strcmp(argv[i], "--mlx-auto-snapshot") == 0 && i + 1 < argc)
			mlx_auto_snapshot = argv[++i];
		else if (strcmp(argv[i], "--mlx-auto-depth") == 0 && i + 1 < argc)
			mlx_auto_depth = argv[++i];

		else if (strcmp(argv[i], "--env-intensity") == 0 && i + 1 < argc)
			env_intensity = atof(argv[++i]);
		else if (strcmp(argv[i], "--no-bvh") == 0)
			use_bvh = 0;
		else if (strcmp(argv[i], "--ao") == 0 && i + 2 < argc)
		{
			ao_radius = atof(argv[++i]);
			ao_samples = atoi(argv[++i]);
			if (ao_radius < 0.0)
				ao_radius = 0.0;
			if (ao_samples < 0)
				ao_samples = 0;
		}
		else if (strcmp(argv[i], "--srgb-textures") == 0)
			srgb_textures = 1;
		else if (strcmp(argv[i], "--exposure") == 0 && i + 1 < argc)
		{
			exposure = atof(argv[++i]);
			if (exposure <= 0.0)
				exposure = 1.0;
		}
		else if (strcmp(argv[i], "--glossy-samples") == 0 && i + 1 < argc)
		{
			glossy_samples = atoi(argv[++i]);
			if (glossy_samples < 1)
				glossy_samples = 1;
		}
		else if (strcmp(argv[i], "--env-samples") == 0 && i + 1 < argc)
		{
			env_samples = atoi(argv[++i]);
			if (env_samples < 0)
				env_samples = 0;
		}
		else if (strcmp(argv[i], "--sky") == 0 && i + 6 < argc)
		{
			sky_top = (t_color){atoi(argv[++i]), atoi(argv[++i]), atoi(argv[++i])};
			sky_bottom = (t_color){atoi(argv[++i]), atoi(argv[++i]), atoi(argv[++i])};
			sky_set = 1;
		}
		else if (strcmp(argv[i], "--clamp") == 0 && i + 1 < argc)
		{
			clamp_value = atof(argv[++i]);
			if (clamp_value < 0.0)
				clamp_value = 0.0;
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
	if (sky_set)
	{
		scene.sky_top = sky_top;
		scene.sky_bottom = sky_bottom;
	}
	scene.enable_bvh = use_bvh;
	scene.ao_radius = ao_radius;
	scene.ao_samples = ao_samples;
	scene.srgb_textures = srgb_textures;
	if (exposure <= 0.0)
		exposure = 1.0;
	if (glossy_samples < 1)
		glossy_samples = 1;
	scene.glossy_samples = glossy_samples;
	scene.env_samples = env_samples;
	scene.id_path = id_out;
	scene.albedo_path = albedo_out;
	scene.position_path = position_out;
	scene.base_seed = base_seed;
	scene.position_range = pos_range;
	scene.clamp_value = clamp_value;
	scene.env_intensity = env_intensity;
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
	int render_threads = threads;
	if (render_threads <= 0)
		render_threads = 4;
	if (render_threads > height)
		render_threads = height;
	if (render_threads < 1)
		render_threads = 1;
	struct timespec start, end;
	clock_gettime(CLOCK_MONOTONIC, &start);
	double avg_luminance = 0.0;
	double max_luminance = 0.0;
	double min_luminance = 0.0;
	double std_luminance = 0.0;
	t_render_frame *frame = NULL;
	char overlay_buf[256];
	if (mlx_overlay_text && *mlx_overlay_text)
		strncpy(overlay_buf, mlx_overlay_text, sizeof(overlay_buf) - 1);
	else
		snprintf(overlay_buf, sizeof(overlay_buf), "Scene: %s", path);
	overlay_buf[sizeof(overlay_buf) - 1] = '\0';
	int render_ok = render_ppm(&scene, out, width, height, samples, render_threads, gamma, max_depth, depth_out, normal_out, id_out, albedo_out, position_out, tonemap, binary, binary_buffers, exposure, &avg_luminance, &max_luminance, &min_luminance, &std_luminance, &frame);
	clock_gettime(CLOCK_MONOTONIC, &end);
	if (render_ok)
	{
		printf("Rendered to %s (%dx%d, %d sample%s, %s threads, gamma=%.2f, exposure=%.2f, maxdepth=%d, %s ppm).\n",
			   out, width, height, samples, (samples > 1 ? "s" : ""), (threads > 0 ? "custom" : "auto"), gamma, exposure, max_depth, binary ? "P6" : "P3");
		if (depth_out)
			printf("Depth map written to %s.\n", depth_out);
		if (normal_out)
			printf("Normal map written to %s.\n", normal_out);
		if (id_out)
			printf("ID map written to %s.\n", id_out);
		if (tonemap == TM_REINHARD)
			printf("Tonemap: Reinhard.\n");
		else if (tonemap == TM_ACES)
			printf("Tonemap: ACES.\n");
		printf("Intégrer MLX pour l'affichage temps réel (option --mlx).\n");
		if (mlx_auto_snapshot && frame)
		{
			if (write_frame_snapshot(frame, mlx_auto_snapshot) == 0)
				printf("Saved auto snapshot %s\n", mlx_auto_snapshot);
			else
				fprintf(stderr, "Failed auto snapshot %s\n", mlx_auto_snapshot);
		}
		if (mlx_auto_depth && frame)
		{
			if (write_depth_snapshot(frame, mlx_auto_depth) == 0)
				printf("Saved auto depth %s\n", mlx_auto_depth);
			else
				fprintf(stderr, "Failed auto depth %s\n", mlx_auto_depth);
		}
		if (use_mlx && frame)
		{
			const char *overlay_to_use;
			if (mlx_overlay_text && *mlx_overlay_text)
				overlay_to_use = mlx_overlay_text;
			else
				overlay_to_use = overlay_buf;
			if (display_frame_with_mlx(frame, mlx_snapshot_path, mlx_depth_path, overlay_to_use) != 0)
				fprintf(stderr, "MLX preview unavailable; continue without display.\n");
		}
	}
	size_t lights_count = scene.lights_count;
	if (stats_json && stats_json[0] == '-' && stats_json[1] == '\0')
		stats_json_stdout = 1;
	if (render_ok && (stats_out || stats_json || stats_csv || stats_console))
	{
		double seconds = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
		time_t now = time(NULL);
		char timestr[64];
		struct tm stm;
		if (localtime_r(&now, &stm))
			strftime(timestr, sizeof(timestr), "%Y-%m-%dT%H:%M:%S%z", &stm);
		else
			snprintf(timestr, sizeof(timestr), "%ld", (long)now);
		const char *comment_src = stats_comment;
		if ((!comment_src || !*comment_src) && stats_comment_env)
			comment_src = getenv(stats_comment_env);
		char stats_comment_buf[256];
		char env_summary_tmp[256];
		char env_summary_buf[256];
		char tag_summary_tmp[256];
		char tag_summary_buf[256];
		sanitize_comment(stats_comment_buf, sizeof(stats_comment_buf), comment_src);
		tag_summary_buf[0] = '\0';
		if (stats_tag_count > 0)
		{
			build_tag_summary(tag_summary_tmp, sizeof(tag_summary_tmp), stats_tags, stats_tag_count);
			sanitize_comment(tag_summary_buf, sizeof(tag_summary_buf), tag_summary_tmp);
		}
		env_summary_buf[0] = '\0';
		if (stats_env_count > 0)
		{
			build_env_summary(env_summary_tmp, sizeof(env_summary_tmp), stats_env, stats_env_count);
			sanitize_comment(env_summary_buf, sizeof(env_summary_buf), env_summary_tmp);
		}
		double duration = (stats_ms ? (seconds * 1000.0) : seconds);
		double fps = (stats_fps && seconds > 0.0) ? (samples / seconds) : 0.0;
		if (stats_out)
		{
			FILE *sf = fopen(stats_out, stats_append ? "a" : "w");
			if (sf)
			{
				fprintf(sf, "width=%d\nheight=%d\nsamples=%d\nthreads=%d\ngamma=%.2f\nmax_depth=%d\nexposure=%.2f\nbinary=%d\nbinary_buffers=%d\nglossy_samples=%d\nenv_samples=%d\npos_range=%.2f\nclamp=%.2f\nao_samples=%d\nenv_intensity=%.2f\nlights=%zu\nseed=%u\navg_luminance=%.6f\nmax_luminance=%.6f\nmin_luminance=%.6f\nstd_luminance=%.6f\nduration=%.6f\n",
					width, height, samples, render_threads, gamma, max_depth, exposure, binary, binary_buffers, glossy_samples, env_samples, pos_range, clamp_value, ao_samples, env_intensity, lights_count, base_seed, avg_luminance, max_luminance, min_luminance, std_luminance, seconds);
				fprintf(sf, "duration_unit=%s\n", stats_ms ? "ms" : "s");
				if (stats_fps)
					fprintf(sf, "fps=%.2f\n", fps);
				fprintf(sf, "comment=%s\n", stats_comment_buf);
				fprintf(sf, "tags=%s\n", tag_summary_buf);
				if (stats_env_count > 0)
					fprintf(sf, "env_vars=%s\n", env_summary_buf);
				if (stats_camera)
					fprintf(sf, "cam_pos=%.2f,%.2f,%.2f\ncam_dir=%.2f,%.2f,%.2f\n",
							scene.camera.pos.x, scene.camera.pos.y, scene.camera.pos.z,
							scene.camera.dir.x, scene.camera.dir.y, scene.camera.dir.z);
				if (stats_group)
					fprintf(sf, "group=%s\n", stats_group);
				fprintf(sf, "scene=%s\ntimestamp=%s\n", path, timestr);
				fclose(sf);
			}
			else
				perror("fopen stats");
		}
		if (stats_json)
		{
			FILE *jf = stats_json_stdout ? stdout : fopen(stats_json, stats_append ? "a" : "w");
			if (jf)
			{
				fprintf(jf, "{\"timestamp\":\"%s\",\"scene\":\"%s\",\"width\":%d,\"height\":%d,\"samples\":%d,\"threads\":%d,\"gamma\":%.2f,\"max_depth\":%d,\"exposure\":%.2f,\"binary\":%d,\"binary_buffers\":%d,\"glossy_samples\":%d,\"env_samples\":%d,\"pos_range\":%.2f,\"clamp\":%.2f,\"ao_samples\":%d,\"env_intensity\":%.2f,\"lights\":%zu,\"seed\":%u",
						timestr, path, width, height, samples, render_threads, gamma, max_depth, exposure, binary, binary_buffers, glossy_samples, env_samples, pos_range, clamp_value, ao_samples, env_intensity, lights_count, base_seed);
				fprintf(jf, ",\"avg_luminance\":%.6f,\"max_luminance\":%.6f,\"min_luminance\":%.6f,\"std_luminance\":%.6f,\"duration\":%.6f",
						avg_luminance, max_luminance, min_luminance, std_luminance, seconds);
				fprintf(jf, ",\"duration_ms\":%.3f", seconds * 1000.0);
				fprintf(jf, ",\"comment\":\"");
				json_escape(jf, stats_comment_buf);
				fprintf(jf, "\"");
				fprintf(jf, ",\"tags\":\"");
				json_escape(jf, tag_summary_buf);
				fprintf(jf, "\"");
				if (stats_env_count > 0)
				{
					fprintf(jf, ",\"env_vars\":\"");
					json_escape(jf, env_summary_buf);
					fprintf(jf, "\"");
				}
				if (stats_camera)
					fprintf(jf, ",\"cam_pos\":\"%.2f,%.2f,%.2f\",\"cam_dir\":\"%.2f,%.2f,%.2f\"",
							scene.camera.pos.x, scene.camera.pos.y, scene.camera.pos.z,
							scene.camera.dir.x, scene.camera.dir.y, scene.camera.dir.z);
				if (stats_group)
				{
					fprintf(jf, ",\"group\":\"");
					json_escape(jf, stats_group);
					fprintf(jf, "\"");
				}
				if (stats_fps)
					fprintf(jf, ",\"fps\":%.2f", fps);
				fprintf(jf, "}\n");
				if (!stats_json_stdout)
					fclose(jf);
			}
		}
		FILE *console_f = stats_console_stdout ? stdout : stderr;
		if (stats_console && !stats_console_json)
		{
			fprintf(console_f, "[stats] scene=%s width=%d height=%d samples=%d threads=%d gamma=%.2f max_depth=%d exposure=%.2f binary=%d binary_buffers=%d glossy_samples=%d env_samples=%d pos_range=%.2f clamp=%.2f ao_samples=%d env_intensity=%.2f lights=%zu seed=%u duration=%.6f duration_ms=%.3f duration_unit=%s comment=%s",
					path, width, height, samples, render_threads, gamma, max_depth, exposure, binary, binary_buffers, glossy_samples, env_samples, pos_range, clamp_value, ao_samples, env_intensity, lights_count, base_seed, seconds, duration * 1000.0, stats_ms ? "ms" : "s", stats_comment_buf);
			if (stats_tag_count > 0)
				fprintf(console_f, " tags=%s", tag_summary_buf);
			if (stats_group)
				fprintf(console_f, " group=%s", stats_group);
			if (stats_env_count > 0)
			fprintf(console_f, " env_vars=%s", env_summary_buf);
			if (stats_fps)
				fprintf(console_f, " fps=%.2f", fps);
			fprintf(console_f, "\n");
			if (stats_camera)
				fprintf(console_f, "[stats-camera] cam_pos=%.2f,%.2f,%.2f cam_dir=%.2f,%.2f,%.2f avg_lum=%.6f max_lum=%.6f min_lum=%.6f std_lum=%.6f\n",
						scene.camera.pos.x, scene.camera.pos.y, scene.camera.pos.z,
						scene.camera.dir.x, scene.camera.dir.y, scene.camera.dir.z,
						avg_luminance, max_luminance, min_luminance, std_luminance);
		}
		if (stats_console_json)
		{
			fprintf(console_f, "{\"timestamp\":\"%s\",\"scene\":\"", timestr);
			json_escape(console_f, path);
			fprintf(console_f, "\",\"width\":%d,\"height\":%d,\"samples\":%d,\"threads\":%d,\"gamma\":%.2f,\"max_depth\":%d,\"exposure\":%.2f,\"binary\":%d,\"binary_buffers\":%d,\"glossy_samples\":%d,\"env_samples\":%d,\"pos_range\":%.2f,\"clamp\":%.2f,\"ao_samples\":%d,\"env_intensity\":%.2f,\"lights\":%zu,\"seed\":%u,\"duration\":%.6f",
					width, height, samples, render_threads, gamma, max_depth, exposure, binary, binary_buffers, glossy_samples, env_samples, pos_range, clamp_value, ao_samples, env_intensity, lights_count, base_seed, seconds);
			fprintf(console_f, ",\"duration_ms\":%.3f,\"duration_unit\":\"%s\",\"comment\":\"", seconds * 1000.0, stats_ms ? "ms" : "s");
			json_escape(console_f, stats_comment_buf);
			fprintf(console_f, "\"");
			if (stats_env_count > 0)
			{
				fprintf(console_f, ",\"env_vars\":\"");
				json_escape(console_f, env_summary_buf);
				fprintf(console_f, "\"");
			}
			if (stats_camera)
				fprintf(console_f, ",\"cam_pos\":\"%.2f,%.2f,%.2f\",\"cam_dir\":\"%.2f,%.2f,%.2f\"",
						scene.camera.pos.x, scene.camera.pos.y, scene.camera.pos.z,
						scene.camera.dir.x, scene.camera.dir.y, scene.camera.dir.z);
			if (stats_tag_count > 0)
			{
				fprintf(console_f, ",\"tags\":\"");
				json_escape(console_f, tag_summary_buf);
				fprintf(console_f, "\"");
			}
			if (stats_group)
			{
				fprintf(console_f, ",\"group\":\"");
				json_escape(console_f, stats_group);
				fprintf(console_f, "\"");
			}
			if (stats_env_count > 0)
			{
				fprintf(console_f, ",\"env_vars\":\"");
				json_escape(console_f, env_summary_buf);
				fprintf(console_f, "\"");
			}
			fprintf(console_f, "}\n");
		}
		if (stats_csv)
		{
			FILE *cf = stats_csv_stdout ? stdout : fopen(stats_csv, stats_csv_append ? "a+" : "w");
			if (cf)
			{
				int need_header = stats_csv_stdout ? 1 : !stats_csv_append;
				if (!stats_csv_stdout && stats_csv_append)
				{
					if (fseek(cf, 0, SEEK_END) == 0)
						need_header = (ftell(cf) == 0);
				}
				if (need_header)
				{
				fprintf(cf, "timestamp,scene,width,height,samples,threads,gamma,max_depth,exposure,binary,binary_buffers,glossy_samples,env_samples,pos_range,clamp,ao_samples,env_intensity,lights,seed,avg_luminance,max_luminance,min_luminance,std_luminance,duration,fps,comment,tags,env_vars,group");
					if (stats_camera)
						fprintf(cf, ",cam_pos_x,cam_pos_y,cam_pos_z,cam_dir_x,cam_dir_y,cam_dir_z");
				fprintf(cf, "\n");
				}
				fprintf(cf, "\"%s\",\"%s\",%d,%d,%d,%d,%.2f,%d,%.2f,%d,%d,%d,%d,%.2f,%.2f,%d,%.2f,%zu,%u,%.6f,%.6f,%.6f,%.6f,%.6f",
						timestr, path, width, height, samples, render_threads, gamma, max_depth, exposure, binary, binary_buffers, glossy_samples, env_samples, pos_range, clamp_value, ao_samples, env_intensity, lights_count, base_seed, avg_luminance, max_luminance, min_luminance, std_luminance, seconds);
				if (stats_fps)
					fprintf(cf, ",%.2f", fps);
				else
					fprintf(cf, ",");
				fprintf(cf, ",%.3f", seconds * 1000.0);
				fprintf(cf, ",");
				csv_escape(cf, stats_comment_buf);
				fprintf(cf, ",");
				csv_escape(cf, tag_summary_buf);
				fprintf(cf, ",");
				csv_escape(cf, env_summary_buf);
				fprintf(cf, ",");
				csv_escape(cf, stats_group ? stats_group : "");
				if (stats_camera)
					fprintf(cf, ",%.2f,%.2f,%.2f,%.2f,%.2f,%.2f",
							scene.camera.pos.x, scene.camera.pos.y, scene.camera.pos.z,
							scene.camera.dir.x, scene.camera.dir.y, scene.camera.dir.z);
				fprintf(cf, "\n");
				if (!stats_csv_stdout)
					fclose(cf);
			}
			else
				perror("fopen stats csv");
		}
	}
	if (frame)
	{
		free_render_frame(frame);
		free(frame);
		frame = NULL;
	}
	free_scene(&scene);
	return EXIT_SUCCESS;
}
