# Invalid: move is X instead of L/R
states: q0,q1,qacc
alphabet: a_
blank: _
initial: q0
accept: qacc

q0 a -> q1 a X
