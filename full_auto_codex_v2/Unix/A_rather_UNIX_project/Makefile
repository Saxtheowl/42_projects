HOSTTYPE ?= $(shell uname -m)_$(shell uname -s)

NAME = libft_malloc_$(HOSTTYPE).so
LINK_NAME = libft_malloc.so

CC = cc
CFLAGS = -Wall -Wextra -Werror -fPIC -Iinc -Ilibft
LDFLAGS = -shared
LDLIBS = -lpthread

LIBFT_DIR = libft
LIBFT = $(LIBFT_DIR)/libft.a

SRCS = \
	src/core/malloc_state.c \
	src/core/utils.c \
	src/core/malloc.c \
	src/core/show_alloc_mem.c

OBJS = $(SRCS:.c=.o)

all: $(NAME) $(LINK_NAME)

$(NAME): $(OBJS) $(LIBFT)
	$(CC) $(LDFLAGS) $(OBJS) $(LIBFT) $(LDLIBS) -o $@

$(LINK_NAME): $(NAME)
	ln -sf $(NAME) $(LINK_NAME)

$(LIBFT):
	$(MAKE) -C $(LIBFT_DIR)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)
	$(MAKE) -C $(LIBFT_DIR) clean

fclean: clean
	rm -f $(NAME) $(LINK_NAME)
	$(MAKE) -C $(LIBFT_DIR) fclean

re: fclean all

.PHONY: all clean fclean re
