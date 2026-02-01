# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::   #
#    Makefile                                           :+:      :+:    :+:   #
#                                                     +:+ +:+         +:+     #
#    By: claude <claude@anthropic.com>              +#+  +:+       +#+        #
#                                                 +#+#+#+#+#+   +#+           #
#    Created: 2024/01/01 00:00:00 by claude            #+#    #+#             #
#    Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       #
#                                                                              #
# **************************************************************************** #

NAME = minishell

CC = cc
CFLAGS = -Wall -Wextra -Werror

SRC_DIR = src
OBJ_DIR = obj

SRCS = main.c \
       utils.c \
       utils2.c \
       lexer.c \
       parser.c \
       executor.c \
       builtins.c \
       builtin_echo.c \
       builtin_cd.c \
       builtin_pwd.c \
       builtin_export.c \
       builtin_unset.c \
       builtin_env.c \
       builtin_exit.c \
       env.c \
       expand.c \
       redirect.c \
       signals.c \
       path.c \
       readline_compat.c

OBJS = $(addprefix $(OBJ_DIR)/, $(SRCS:.c=.o))

# Check if readline is available
READLINE_CHECK := $(shell echo '\#include <readline/readline.h>' | $(CC) -E - 2>/dev/null && echo yes)

ifeq ($(READLINE_CHECK),yes)
    CFLAGS += -DUSE_READLINE
    LDFLAGS = -lreadline
else
    LDFLAGS =
endif

all: $(NAME)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJS) $(LDFLAGS)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
