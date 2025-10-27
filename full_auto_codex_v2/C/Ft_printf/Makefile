NAME := libftprintf.a
CC := cc
CFLAGS := -Wall -Wextra -Werror
INCLUDES := -Iinclude
SRC_DIR := src
OBJ_DIR := build

SRCS := \
	core/buffer.c \
	core/ft_printf.c \
	core/conversion.c \
	conversions/convert_char.c \
	conversions/convert_string.c \
	conversions/convert_percent.c \
	conversions/convert_signed.c \
	conversions/convert_unsigned.c \
	conversions/convert_hex.c \
	conversions/convert_pointer.c \
	utils/string_utils.c \
	utils/number_utils.c

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

.PHONY: all clean fclean re
