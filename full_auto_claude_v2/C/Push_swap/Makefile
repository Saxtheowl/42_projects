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

NAME = push_swap
BONUS = checker

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

SRCS = push_swap.c \
       operations.c \
       rotate.c \
       stack_utils.c \
       stack_utils2.c \
       parse.c \
       validation.c \
       sort_small.c \
       radix_sort.c \
       utils.c \
       ft_split.c

SRCS_BONUS = checker_bonus.c \
             operations.c \
             rotate.c \
             stack_utils.c \
             stack_utils2.c \
             parse.c \
             validation.c \
             utils.c \
             ft_split.c

OBJS = $(SRCS:.c=.o)
OBJS_BONUS = $(SRCS_BONUS:.c=.o)

GREEN = \033[0;32m
NC = \033[0m

all: $(NAME)

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME)
	@echo "$(GREEN)push_swap compiled successfully$(NC)"

bonus: $(BONUS)

$(BONUS): $(OBJS_BONUS)
	@$(CC) $(CFLAGS) $(OBJS_BONUS) -o $(BONUS)
	@echo "$(GREEN)checker compiled successfully$(NC)"

%.o: %.c push_swap.h
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "Compiled: $<"

clean:
	@$(RM) $(OBJS) $(OBJS_BONUS)
	@echo "Object files cleaned"

fclean: clean
	@$(RM) $(NAME) $(BONUS)
	@echo "Executables removed"

re: fclean all

.PHONY: all bonus clean fclean re
