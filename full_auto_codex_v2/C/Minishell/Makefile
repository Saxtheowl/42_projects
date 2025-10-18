NAME        := minishell
CC          := cc
CFLAGS      := -Wall -Wextra -Werror -MMD -MP
INCLUDES    := -Iinclude
LIBS        :=

ifeq ($(USE_SYSTEM_READLINE),1)
LIBS        += -lreadline -lncurses
CFLAGS      += -DMS_FORCE_READLINE
endif

SRC_DIR     := src
BUILD_DIR   := build

SRCS        := \
	core/minishell.c \
	builtins/builtins.c \
	env/env.c \
	lexer/lexer.c \
	lexer/token.c \
	executor/executor.c \
	parser/ast.c \
	parser/parser.c \
	prompt/prompt.c \
	prompt/readline_stub.c \
	signals/signals.c \
	main.c

SRCS        := $(addprefix $(SRC_DIR)/,$(SRCS))
OBJS        := $(addprefix $(BUILD_DIR)/,$(SRCS:.c=.o))
DEPS        := $(OBJS:.o=.d)

all: $(NAME)

$(NAME): $(OBJS)
	@printf "Linking %s\n" $(NAME)
	@$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $@

$(BUILD_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@printf "Compiling %s\n" $<
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	@rm -rf $(BUILD_DIR)

fclean: clean
	@rm -f $(NAME)

re: fclean all

norm:
	@norminette $(SRC_DIR) include

run: $(NAME)
	@./$(NAME)

.PHONY: all clean fclean re norm run

-include $(DEPS)
