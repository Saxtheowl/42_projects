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

NAME = pipex

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

# Source files
SRCS = pipex.c utils.c ft_split.c path.c pipex_bonus.c here_doc_bonus.c

# Object files
OBJS = $(SRCS:.c=.o)

# Colors for output
GREEN = \033[0;32m
NC = \033[0m

# Default target
all: $(NAME)

# Create executable
$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "$(GREEN)✅ $(NAME) compiled successfully$(NC)"

# Compile .c to .o
%.o: %.c pipex.h
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled: $<"

# Clean object files
clean:
	@$(RM) $(OBJS)
	@echo "🧹 Object files cleaned"

# Clean everything
fclean: clean
	@$(RM) $(NAME)
	@echo "🧹 Executable removed"

# Rebuild everything
re: fclean all

# Test targets
test: $(NAME)
	@echo "\n=== Testing basic pipex ==="
	@echo "Test content" > infile
	@./pipex infile "cat" "wc -l" outfile
	@echo "Expected: 1"
	@echo -n "Got: "
	@cat outfile
	@rm -f infile outfile

# Phony targets
.PHONY: all clean fclean re test
