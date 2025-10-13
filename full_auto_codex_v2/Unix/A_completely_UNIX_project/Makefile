NAME_NM = ft_nm
NAME_OTOOL = ft_otool

CC = cc
CFLAGS = -Wall -Wextra -Werror -Iinc -Ilibft

LIBFT_DIR = libft
LIBFT = $(LIBFT_DIR)/libft.a

SRCS_COMMON = \
	src/common/file_map.c \
	src/common/macho.c

SRCS_NM = \
	src/nm/main.c \
	src/nm/nm.c

SRCS_OTOOL = \
	src/otool/main.c \
	src/otool/otool.c

OBJS_COMMON = $(SRCS_COMMON:.c=.o)
OBJS_NM = $(SRCS_NM:.c=.o)
OBJS_OTOOL = $(SRCS_OTOOL:.c=.o)

all: $(NAME_NM) $(NAME_OTOOL)

$(LIBFT):
	$(MAKE) -C $(LIBFT_DIR)

$(NAME_NM): $(LIBFT) $(OBJS_COMMON) $(OBJS_NM)
	$(CC) $(CFLAGS) $(OBJS_COMMON) $(OBJS_NM) $(LIBFT) -o $(NAME_NM)

$(NAME_OTOOL): $(LIBFT) $(OBJS_COMMON) $(OBJS_OTOOL)
	$(CC) $(CFLAGS) $(OBJS_COMMON) $(OBJS_OTOOL) $(LIBFT) -o $(NAME_OTOOL)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS_COMMON) $(OBJS_NM) $(OBJS_OTOOL)
	$(MAKE) -C $(LIBFT_DIR) clean

fclean: clean
	rm -f $(NAME_NM) $(NAME_OTOOL)
	$(MAKE) -C $(LIBFT_DIR) fclean

re: fclean all

.PHONY: all clean fclean re
