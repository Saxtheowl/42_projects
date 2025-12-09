#include "mlx_bridge.h"
#include <stdio.h>
#include <string.h>
#include <math.h>

static int clamp_byte(int v)
{
    if (v < 0)
        return 0;
    if (v > 255)
        return 255;
    return v;
}

int write_frame_snapshot(const t_render_frame *frame, const char *path)
{
    if (!frame || !frame->colors || frame->width <= 0 || frame->height <= 0)
        return -1;
    FILE *f = fopen(path, "w");
    if (!f)
        return -1;
    fprintf(f, "P3\n%d %d\n255\n", frame->width, frame->height);
    for (int y = frame->height - 1; y >= 0; --y)
    {
        for (int x = 0; x < frame->width; ++x)
        {
            t_color c = frame->colors[y * frame->width + x];
            fprintf(f, "%d %d %d ", c.r, c.g, c.b);
        }
        fprintf(f, "\n");
    }
    fclose(f);
    return 0;
}

int write_depth_snapshot(const t_render_frame *frame, const char *path)
{
    if (!frame || !frame->depths || frame->width <= 0 || frame->height <= 0)
        return -1;
    double maxd = 0.0;
    int total = frame->width * frame->height;
    for (int i = 0; i < total; ++i)
        if (frame->depths[i] > maxd)
            maxd = frame->depths[i];
    FILE *f = fopen(path, "w");
    if (!f)
        return -1;
    fprintf(f, "P3\n%d %d\n255\n", frame->width, frame->height);
    for (int y = frame->height - 1; y >= 0; --y)
    {
        for (int x = 0; x < frame->width; ++x)
        {
            double d = frame->depths[y * frame->width + x];
            int v = 0;
            if (d > 0 && maxd > 0)
                v = clamp_byte((int)((1.0 - fmin(d / maxd, 1.0)) * 255.0));
            fprintf(f, "%d %d %d ", v, v, v);
        }
        fprintf(f, "\n");
    }
    fclose(f);
    return 0;
}

#ifdef USE_MLX
# include "mlx.h"
# include <stdlib.h>

typedef struct s_mlx_state
{
	void	*mlx;
	void	*win;
	void	*img;
	int		width;
	int		height;
	const t_render_frame *frame;
	char	snapshot_path[256];
	char	depth_path[256];
	char	overlay_text[256];
}	t_mlx_state;

static int	close_hook(void *param)
{
	t_mlx_state *state = (t_mlx_state *)param;
	if (state->mlx)
		mlx_loop_end(state->mlx);
	return 0;
}

static int	key_hook(int key, void *param)
{
	t_mlx_state *state = (t_mlx_state *)param;
	(void)state;
	if (key == 53 || key == 65307)
	{
		if (state->mlx)
			mlx_loop_end(state->mlx);
	}
	else if (key == 115 || key == 83)
	{
		if (state && state->frame)
		{
			if (write_frame_snapshot(state->frame, state->snapshot_path) == 0)
				printf("Saved snapshot %s\n", state->snapshot_path);
			else
				fprintf(stderr, "Failed to save MLX snapshot\n");
		}
	}
	else if (key == 100 || key == 68)
	{
		if (state && state->frame && state->depth_path[0])
		{
			if (write_depth_snapshot(state->frame, state->depth_path) == 0)
				printf("Saved depth %s\n", state->depth_path);
			else
				fprintf(stderr, "Failed to save MLX depth\n");
		}
	}
	return 0;
}

static void	put_color(char *data, int bpp, int size_line, int endian, int x, int y, t_color c)
{
	int	index = y * size_line + x * (bpp / 8);
	if (index < 0)
		return;
	unsigned int pixel = (unsigned int)c.r << 16 | (unsigned int)c.g << 8 | (unsigned int)c.b;
	if (endian == 0)
	{
		data[index + 0] = (pixel) & 0xFF;
		data[index + 1] = (pixel >> 8) & 0xFF;
		data[index + 2] = (pixel >> 16) & 0xFF;
	}
	else
	{
		data[index + 0] = (pixel >> 16) & 0xFF;
		data[index + 1] = (pixel >> 8) & 0xFF;
		data[index + 2] = (pixel) & 0xFF;
	}
}

static int	blit_frame(t_mlx_state *state, const t_render_frame *frame)
{
	int bpp;
	int size_line;
	int endian;
	char *data = mlx_get_data_addr(state->img, &bpp, &size_line, &endian);
	if (!data)
		return -1;
	for (int y = 0; y < frame->height; ++y)
	{
		for (int x = 0; x < frame->width; ++x)
		{
			t_color c = frame->colors[y * frame->width + x];
			put_color(data, bpp, size_line, endian, x, frame->height - 1 - y, c);
		}
	}
	mlx_put_image_to_window(state->mlx, state->win, state->img, 0, 0);
	return 0;
}

int	display_frame_with_mlx(const t_render_frame *frame, const char *snapshot_path, const char *depth_path, const char *overlay_text)
{
	if (!frame || !frame->colors || frame->width <= 0 || frame->height <= 0)
		return -1;
	t_mlx_state state = {0};
	state.width = frame->width;
	state.height = frame->height;
	state.mlx = mlx_init();
	if (!state.mlx)
		return -1;
	state.frame = frame;
	if (snapshot_path)
		strncpy(state.snapshot_path, snapshot_path, sizeof(state.snapshot_path) - 1);
	else
		strncpy(state.snapshot_path, "mlx_snapshot.ppm", sizeof(state.snapshot_path) - 1);
	state.snapshot_path[sizeof(state.snapshot_path) - 1] = '\0';
	if (depth_path)
		strncpy(state.depth_path, depth_path, sizeof(state.depth_path) - 1);
	else
		strncpy(state.depth_path, "mlx_depth.ppm", sizeof(state.depth_path) - 1);
	state.depth_path[sizeof(state.depth_path) - 1] = '\0';
	if (overlay_text)
		strncpy(state.overlay_text, overlay_text, sizeof(state.overlay_text) - 1);
	else
		strncpy(state.overlay_text, "", sizeof(state.overlay_text) - 1);
	state.overlay_text[sizeof(state.overlay_text) - 1] = '\0';
	state.snapshot_path[sizeof(state.snapshot_path) - 1] = '\0';
	state.win = mlx_new_window(state.mlx, frame->width, frame->height, "Graphical_Project Preview");
	if (!state.win)
	{
		mlx_destroy_display(state.mlx);
		free(state.mlx);
		return -1;
	}
	state.img = mlx_new_image(state.mlx, frame->width, frame->height);
	if (!state.img)
	{
		mlx_destroy_window(state.mlx, state.win);
		free(state.mlx);
		return -1;
	}
	if (blit_frame(&state, frame) != 0)
	{
		mlx_destroy_image(state.mlx, state.img);
		mlx_destroy_window(state.mlx, state.win);
		mlx_destroy_display(state.mlx);
		free(state.mlx);
		return -1;
	}
	if (state.overlay_text[0])
		mlx_string_put(state.mlx, state.win, 10, 20, 0xFFFFFF, state.overlay_text);
	mlx_hook(state.win, 17, 0, close_hook, &state);
	mlx_key_hook(state.win, key_hook, &state);
	mlx_loop(state.mlx);
	mlx_destroy_image(state.mlx, state.img);
	mlx_destroy_window(state.mlx, state.win);
	mlx_destroy_display(state.mlx);
	free(state.mlx);
	return 0;
}

#else

int	display_frame_with_mlx(const t_render_frame *frame, const char *snapshot_path, const char *depth_path, const char *overlay_text)
{
	(void)frame;
	(void)snapshot_path;
	(void)depth_path;
	(void)overlay_text;
	fprintf(stderr, "MLX preview disabled: compile with USE_MLX to enable.\n");
	return -1;
}

#endif
