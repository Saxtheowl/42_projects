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

NAME = philo

CC = cc
CFLAGS = -Wall -Wextra -Werror -pthread
RM = rm -f

# Source files
SRCS = main.c init.c utils.c routine.c monitor.c

# Object files
OBJS = $(SRCS:.c=.o)

# Colors
GREEN = \033[0;32m
NC = \033[0m

# Default target
all: $(NAME)

# Create executable
$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "$(GREEN)philo compiled successfully$(NC)"

# Compile .c to .o
%.o: %.c philo.h
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

# Phony targets
.PHONY: all clean fclean re
