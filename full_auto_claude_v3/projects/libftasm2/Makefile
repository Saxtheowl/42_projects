# libftasm2 Makefile - Extended Assembly Library

NAME = libftasm2.a
ASM = nasm
AFLAGS = -f elf64
AR = ar
ARFLAGS = rcs

SRC = libftasm2.s
OBJ = $(SRC:.s=.o)

# Test program
TEST = test_libftasm2
CC = gcc
CFLAGS = -Wall -Wextra -Werror

all: $(NAME)

$(NAME): $(OBJ)
	$(AR) $(ARFLAGS) $(NAME) $(OBJ)

%.o: %.s
	$(ASM) $(AFLAGS) $< -o $@

test: $(NAME) test_main.c
	$(CC) $(CFLAGS) -o $(TEST) test_main.c -L. -lftasm2

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME) $(TEST)

re: fclean all

.PHONY: all clean fclean re test
