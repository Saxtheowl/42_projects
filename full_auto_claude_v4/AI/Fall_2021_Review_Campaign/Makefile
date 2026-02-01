NAME = bsq

CC = gcc
CFLAGS = -Wall -Wextra -Werror -O2

SRC_DIR = src
INC_DIR = include
OBJ_DIR = obj

SRCS = $(SRC_DIR)/main.c \
       $(SRC_DIR)/map_parse.c \
       $(SRC_DIR)/map_validate.c \
       $(SRC_DIR)/map_utils.c \
       $(SRC_DIR)/solver.c \
       $(SRC_DIR)/io_utils.c \
       $(SRC_DIR)/string_utils.c

OBJS = $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(INC_DIR)/bsq.h | $(OBJ_DIR)
	$(CC) $(CFLAGS) -I$(INC_DIR) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
