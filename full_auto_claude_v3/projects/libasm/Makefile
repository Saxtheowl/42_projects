NAME = libasm.a
TEST = test_libasm

AS = as
ASFLAGS = --64
CC = cc
CFLAGS = -Wall -Wextra -Werror

SRCDIR = src
SRCS = $(SRCDIR)/ft_strlen.s $(SRCDIR)/ft_strcpy.s $(SRCDIR)/ft_strcmp.s \
       $(SRCDIR)/ft_write.s $(SRCDIR)/ft_read.s $(SRCDIR)/ft_strdup.s
OBJS = $(SRCS:.s=.o)

all: $(NAME)

$(NAME): $(OBJS)
	ar rcs $(NAME) $(OBJS)

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

test: $(NAME) main.c
	$(CC) $(CFLAGS) main.c -L. -lasm -o $(TEST)
	./$(TEST)

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME) $(TEST)

re: fclean all

.PHONY: all clean fclean re test
