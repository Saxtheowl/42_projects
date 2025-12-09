#pragma once

#include "scene.h"

typedef enum e_tonemap
{
	TM_NONE = 0,
	TM_REINHARD = 1,
	TM_ACES = 2
}	t_tonemap;

/* texture sampling */
t_color	sample_texture(const t_texture *tex, double u, double v);
void	attach_texture(t_scene *scene, t_texture *tex);

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma, int max_depth, const char *depth_path, const char *normal_path, t_tonemap tonemap, int binary);
