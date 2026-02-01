# lem_ipc Makefile

NAME = lem_ipc
CC = gcc
CFLAGS = -Wall -Wextra -Werror

SRC = lem_ipc.c
OBJ = $(SRC:.c=.o)

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) -o $(NAME) $(OBJ)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f $(NAME)

# Clean up IPC resources
ipc_clean:
	@ipcrm -M 0x42424242 2>/dev/null || true
	@ipcrm -S 0x42424243 2>/dev/null || true
	@echo "IPC resources cleaned"

re: fclean all

.PHONY: all clean fclean re ipc_clean
