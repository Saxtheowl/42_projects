# Example machine: adds one to a unary number (a^n)
states: q0,qwrite,qacc
alphabet: a_
blank: _
initial: q0
accept: qacc

# if we read 'a', move right until blank
q0 a -> q0 a R
q0 _ -> qwrite a L

# move left to stabilize and accept
qwrite a -> qwrite a L
qwrite _ -> qacc _ R
