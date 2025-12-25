#pragma once

#include "render.h"

int	display_frame_with_mlx(const t_render_frame *frame, const char *snapshot_path, const char *depth_path, const char *overlay_text);
int	write_frame_snapshot(const t_render_frame *frame, const char *path);
int	write_depth_snapshot(const t_render_frame *frame, const char *path);
