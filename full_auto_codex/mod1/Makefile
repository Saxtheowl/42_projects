NAME := mod1

all:
	@echo "Python project: nothing to compile."

run:
	./mod1 resources/example.mod1 --scenario all --frames 10

tests:
	python3 tests_realisation/run_tests.py

clean:
	rm -rf outputs

fclean: clean

re: fclean all

.PHONY: all run tests clean fclean re
