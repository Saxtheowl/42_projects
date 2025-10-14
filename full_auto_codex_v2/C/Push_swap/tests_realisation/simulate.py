import sys
from collections import deque

ops = [line.strip() for line in sys.stdin.read().splitlines() if line.strip()]
vals = []
for arg in sys.argv[1:]:
    for tok in arg.split():
        vals.append(int(tok))
a = deque(vals)
b = deque()

def sa():
    if len(a) >= 2:
        a[0], a[1] = a[1], a[0]

def sb():
    if len(b) >= 2:
        b[0], b[1] = b[1], b[0]

def ss():
    sa()
    sb()

def pa():
    if b:
        a.appendleft(b.popleft())

def pb():
    if a:
        b.appendleft(a.popleft())

def ra():
    if a:
        a.rotate(-1)

def rb():
    if b:
        b.rotate(-1)

def rr():
    ra()
    rb()

def rra():
    if a:
        a.rotate(1)

def rrb():
    if b:
        b.rotate(1)

def rrr():
    rra()
    rrb()

handlers = {
    "sa": sa,
    "sb": sb,
    "ss": ss,
    "pa": pa,
    "pb": pb,
    "ra": ra,
    "rb": rb,
    "rr": rr,
    "rra": rra,
    "rrb": rrb,
    "rrr": rrr,
}

try:
    for op in ops:
        handlers[op]()
except KeyError:
    print("Error: invalid operation", file=sys.stderr)
    sys.exit(1)

if not all(a[i] <= a[i + 1] for i in range(len(a) - 1)) or b:
    print("KO", file=sys.stderr)
    sys.exit(1)
print("OK")
