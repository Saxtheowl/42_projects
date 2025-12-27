NAME		:= ft_ping
CC		:= cc
CFLAGS		:= -Wall -Wextra -Werror
CPPFLAGS	:= -Iinclude
LDLIBS		:= -lm

SRC_DIR	:= src
OBJ_DIR	:= build
TEST_DIR	:= tests_realisation

SRCS		:= $(SRC_DIR)/main.c \
		   $(SRC_DIR)/options.c \
		   $(SRC_DIR)/ping.c \
		   $(SRC_DIR)/stats.c \
		   $(SRC_DIR)/checksum.c \
		   $(SRC_DIR)/utils.c

OBJS		:= $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDLIBS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

TEST_CHECKSUM := $(OBJ_DIR)/test_checksum
TEST_OPTIONS  := $(OBJ_DIR)/test_options

$(TEST_CHECKSUM): $(TEST_DIR)/test_checksum.c $(SRC_DIR)/checksum.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ $(LDLIBS) -o $@

$(TEST_OPTIONS): $(TEST_DIR)/test_options.c $(SRC_DIR)/options.c $(SRC_DIR)/utils.c | $(OBJ_DIR)
	$(CC) $(CFLAGS) $(CPPFLAGS) $^ $(LDLIBS) -o $@

test: $(TEST_CHECKSUM) $(TEST_OPTIONS)
	$(TEST_CHECKSUM)
	$(TEST_OPTIONS)

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re test
