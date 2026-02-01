CC = cc
CFLAGS = -Wall -Wextra -Werror

all: Colleen Grace Sully

Colleen: Colleen.c
	$(CC) $(CFLAGS) Colleen.c -o Colleen

Grace: Grace.c
	$(CC) $(CFLAGS) Grace.c -o Grace

Sully: Sully.c
	$(CC) $(CFLAGS) Sully.c -o Sully

test: all
	@echo "=== Testing Colleen ==="
	./Colleen > /tmp/colleen_out.c && diff Colleen.c /tmp/colleen_out.c && echo "Colleen: OK"
	@echo "=== Testing Grace ==="
	./Grace > /tmp/grace_out.c && diff Grace.c /tmp/grace_out.c && echo "Grace: OK"
	@echo "=== Testing Sully ==="
	rm -f Sully_1.c
	./Sully && diff Sully.c Sully_1.c && echo "Sully: OK"
	rm -f Sully_1.c

clean:
	rm -f Colleen Grace Sully Sully_1.c /tmp/colleen_out.c /tmp/grace_out.c

.PHONY: all test clean
