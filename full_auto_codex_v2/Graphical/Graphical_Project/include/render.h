#pragma once

#include "scene.h"

int	render_ppm(const t_scene *scene, const char *path, int width, int height, int samples, int threads, double gamma, int max_depth, const char *depth_path);
