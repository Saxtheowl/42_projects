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

NAME = minishell

CC = cc
CFLAGS = -Wall -Wextra -Werror
RM = rm -f

SRCS = main.c \
       lexer.c \
       parser.c \
       expander.c \
       executor.c \
       redirections.c \
       env.c \
       env2.c \
       signals.c \
       utils.c \
       utils2.c \
       utils3.c \
       ft_split.c \
       builtin_echo.c \
       builtin_cd.c \
       builtin_pwd.c \
       builtin_export.c \
       builtin_unset.c \
       builtin_env.c \
       builtin_exit.c

OBJS = $(SRCS:.c=.o)

GREEN = \033[0;32m
NC = \033[0m

all: $(NAME)

$(NAME): $(OBJS)
	@$(CC) $(CFLAGS) $(OBJS) -o $(NAME) -lreadline
	@echo "$(GREEN)minishell compiled successfully$(NC)"

%.o: %.c minishell.h
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
