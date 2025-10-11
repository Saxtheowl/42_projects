ifeq ($(HOSTTYPE),)
HOSTTYPE := $(shell uname -m)_$(shell uname -s)
endif

NAME := libft_malloc_$(HOSTTYPE).so
LINK_NAME := libft_malloc.so
CC := cc
CFLAGS := -Wall -Wextra -Werror -I include -fPIC
LDFLAGS := -shared -pthread
OBJ_DIR := build
SRCS := \
	src/state.c \
	src/utils.c \
	src/zone.c \
	src/dispatch.c \
	src/lookup.c \
	src/malloc.c \
	src/free.c \
	src/realloc.c \
	src/show.c
OBJS := $(SRCS:src/%.c=$(OBJ_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

all: $(NAME)
	@ln -sf $(NAME) $(LINK_NAME)

$(NAME): $(OBJ_DIR) $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: src/%.c
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

clean:
	rm -rf $(OBJ_DIR)

fclean: clean
	rm -f $(NAME) $(LINK_NAME)

re: fclean all

.PHONY: all clean fclean re tests

-include $(DEPS)
