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

NAME = fractol

CC = cc
CFLAGS = -Wall -Wextra -Werror
MLX_FLAGS = -L/usr/local/lib -lmlx -lXext -lX11 -lm
RM = rm -f

SRCS = main.c init.c fractals.c render.c events.c complex.c utils.c
OBJS = $(SRCS:.c=.o)

GREEN = \033[0;32m
NC = \033[0m

all: $(NAME)

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) $(MLX_FLAGS) -o $(NAME)
	@echo "$(GREEN)fractol compiled successfully$(NC)"

%.o: %.c fractol.h
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled: $<"

clean:
	@$(RM) $(OBJS)
	@echo "Object files cleaned"

fclean: clean
	@$(RM) $(NAME)
	@echo "Executable removed"

re: fclean all

.PHONY: all clean fclean re
