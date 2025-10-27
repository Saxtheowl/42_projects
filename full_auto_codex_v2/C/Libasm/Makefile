NAME := libasm.a
NASM := nasm
NASMFLAGS := -f elf64
CC := cc
CFLAGS := -Wall -Wextra -Werror
INCLUDES := -Iinclude
SRC_DIR := src
OBJ_DIR := build

ASM_SRCS := \
	ft_strlen.s \
	ft_strcpy.s \
	ft_strcmp.s \
	ft_write.s \
	ft_read.s \
	ft_strdup.s

ASM_SRCS := $(addprefix $(SRC_DIR)/,$(ASM_SRCS))
ASM_OBJS := $(ASM_SRCS:$(SRC_DIR)/%.s=$(OBJ_DIR)/%.o)

all: $(NAME)

$(NAME): $(ASM_OBJS)
	@printf "Archiving %s\n" $@
	@ar rcs $@ $(ASM_OBJS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(dir $@)
	@printf "Assembling %s\n" $<
	@$(NASM) $(NASMFLAGS) $< -o $@

clean:
	@rm -rf $(OBJ_DIR)

fclean: clean
	@rm -f $(NAME)

re: fclean all

test: all
	@./scripts/run_tests.sh

.PHONY: all clean fclean re test
