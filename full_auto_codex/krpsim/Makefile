PY := python3

all:
	@echo "Python project: nothing to build"

run:
	./krpsim configs/sample_endless.cfg 200

verify:
	./krpsim_verif configs/sample_endless.cfg tests_realisation/sample_trace.txt

clean:
	rm -f tests_realisation/sample*

fclean: clean

re: fclean all

.PHONY: all run verify clean fclean re
