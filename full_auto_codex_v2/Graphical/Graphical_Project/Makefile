NAME := RT
CC := cc
CFLAGS := -Wall -Wextra -Werror -std=c11 -pthread
USE_MLX ?= 0
MLX_LIBS ?= -lmlx -lX11 -lXext
ifeq ($(USE_MLX),1)
CFLAGS += -DUSE_MLX
endif
SRC := src/main.c src/parser.c src/render.c src/mlx_bridge.c
OBJ := $(SRC:.c=.o)
INCLUDES := -Iinclude
LDLIBS := -lm
ifeq ($(USE_MLX),1)
LDLIBS += $(MLX_LIBS)
endif

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LDLIBS) -o $(NAME)

%.o: %.c include/scene.h include/parser.h include/mlx_bridge.h
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
