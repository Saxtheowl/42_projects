NAME := philo
CC := cc
CFLAGS := -Wall -Wextra -Werror -pthread
INCLUDES := -Iinclude
SRC_DIR := src
OBJ_DIR := build

SRCS := \
	main.c \
	config.c \
	log.c \
	monitor.c \
	philo.c \
	run.c \
	simulation.c \
	time.c

SRCS := $(addprefix $(SRC_DIR)/,$(SRCS))
OBJS := $(SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	@printf "Linking %s\n" $@
	@$(CC) $(CFLAGS) $(OBJS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@printf "Compiling %s\n" $<
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
