NAME := libunit.a
CC := cc
CFLAGS := -Wall -Wextra -Werror
INCLUDES := -Iinclude
SRC_DIR := src
OBJ_DIR := build

SRCS := \
	load_test.c \
	launch_tests.c

SRCS := $(addprefix $(SRC_DIR)/,$(SRCS))
OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	@printf "Archiving %s\n" $@
	@ar rcs $@ $(OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@printf "Compiling %s\n" $<
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -f $(NAME)

re: fclean all

test: all
	@./scripts/run_tests.sh

.PHONY: all clean fclean re test
