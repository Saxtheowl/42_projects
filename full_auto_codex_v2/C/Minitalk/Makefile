NAME_SERVER := server
NAME_CLIENT := client
CC := cc
CFLAGS := -Wall -Wextra -Werror
INCLUDES := -Iinclude
SRC_DIR := src
OBJ_DIR := build

COMMON_SRCS := \
	$(SRC_DIR)/utils/string_utils.c \
	$(SRC_DIR)/utils/io_utils.c \
	$(SRC_DIR)/utils/parse_utils.c

SERVER_SRCS := $(SRC_DIR)/server.c $(COMMON_SRCS)
CLIENT_SRCS := $(SRC_DIR)/client.c $(COMMON_SRCS)

SERVER_OBJS := $(SERVER_SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
CLIENT_OBJS := $(CLIENT_SRCS:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)

all: $(NAME_SERVER) $(NAME_CLIENT)

$(NAME_SERVER): $(SERVER_OBJS)
	@mkdir -p $(@D)
	@printf "Linking %s\n" $@
	@$(CC) $(CFLAGS) $(SERVER_OBJS) -o $@

$(NAME_CLIENT): $(CLIENT_OBJS)
	@mkdir -p $(@D)
	@printf "Linking %s\n" $@
	@$(CC) $(CFLAGS) $(CLIENT_OBJS) -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	@printf "Compiling %s\n" $<
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -f $(NAME_SERVER) $(NAME_CLIENT)

re: fclean all

.PHONY: all clean fclean re
