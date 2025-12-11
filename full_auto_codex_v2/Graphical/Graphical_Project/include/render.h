#pragma once

#include "scene.h"

typedef enum e_tonemap
{
	TM_NONE = 0,
	TM_REINHARD = 1,
	TM_ACES = 2
}	t_tonemap;

typedef struct s_render_frame
{
	int		width;
	int		height;
	t_color	*colors;
	double	*depths;
	t_vec3	*normals;
	int		*ids;
	t_color	*albedos;
	t_vec3	*positions;
}	t_render_frame;

/* texture sampling */
t_color	sample_texture(const t_texture *tex, double u, double v);
void	attach_texture(t_scene *scene, t_texture *tex);

int	render_frame(t_render_frame *frame, const t_scene *scene, int width, int height, int samples, int threads, int max_depth, int capture_ids, int capture_albedo, int capture_position);
void	free_render_frame(t_render_frame *frame);

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma, int max_depth, const char *depth_path, const char *normal_path, const char *id_path, const char *albedo_path, const char *position_path, t_tonemap tonemap, int binary, int binary_buffers, double exposure, double *avg_luminance, double *max_luminance, double *min_luminance, double *stddev_luminance, t_render_frame **out_frame);
