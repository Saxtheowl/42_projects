# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: automated <automated@42.fr>                +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/13 00:00:00 by automated         #+#    #+#              #
#    Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = so_long

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

# MiniLibX flags for Linux
MLX_DIR = /usr/local/lib
MLX_FLAGS = -L$(MLX_DIR) -lmlx -lXext -lX11 -lm

# Source files
SRCS = main.c \
       init.c \
       utils.c \
       get_next_line.c \
       map_parser.c \
       map_validation.c \
       render.c \
       game.c \
       events.c

# Object files
OBJS = $(SRCS:.c=.o)

# Colors
GREEN = \033[0;32m
NC = \033[0m

# Default target
all: $(NAME)

# Create executable
$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) $(MLX_FLAGS) -o $(NAME)
	@echo "$(GREEN)so_long compiled successfully$(NC)"

# Compile .c to .o
%.o: %.c so_long.h
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled: $<"

# Clean object files
clean:
	@$(RM) $(OBJS)
	@echo "Object files cleaned"

# Clean everything
fclean: clean
	@$(RM) $(NAME)
	@echo "Executable removed"

# Rebuild everything
re: fclean all

# Test with simple map
test: $(NAME)
	@./$(NAME) maps/simple.ber

# Phony targets
.PHONY: all clean fclean re test
