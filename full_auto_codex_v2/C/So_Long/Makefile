NAME = so_long
MLX ?= 1
MLX_DIR = lib/minilibx
MLX_LIB = $(MLX_DIR)/libmlx_Linux.a

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc
LIBS =

SRCS_COMMON = \
	src/main.c \
	src/utils.c \
	src/map.c \
	src/validate.c

ifeq ($(MLX),0)
SRCS = $(SRCS_COMMON) src/graphics_stub.c
CFLAGS += -DMLX_DISABLED
else
SRCS = $(SRCS_COMMON) src/graphics.c
CFLAGS += -I$(MLX_DIR)
LIBS = -L$(MLX_DIR) -lmlx_Linux -L/usr/lib -lXext -lX11 -lm -lz
endif

OBJS = $(SRCS:.c=.o)

all: $(NAME)

ifeq ($(MLX),0)
$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $(NAME)
else
$(NAME): $(MLX_LIB) $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(MLX_LIB) $(LIBS) -o $(NAME)

$(MLX_LIB):
	$(MAKE) -C $(MLX_DIR)
endif

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)
ifneq ($(MLX),0)
	$(MAKE) -C $(MLX_DIR) clean
endif

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
