EX_DIRS := ex00 ex01 ex02 ex03 ex04

all: $(EX_DIRS)

$(EX_DIRS):
	@$(MAKE) -C $@

clean:
	@for d in $(EX_DIRS); do \
		[ -d $$d ] && $(MAKE) -C $$d clean; \
	done

fclean:
	@for d in $(EX_DIRS); do \
		[ -d $$d ] && $(MAKE) -C $$d fclean; \
	done

re: fclean all

.PHONY: all clean fclean re $(EX_DIRS)
