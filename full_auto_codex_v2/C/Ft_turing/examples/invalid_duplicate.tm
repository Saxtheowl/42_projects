# Invalid: duplicate transition on (q0, a)
states: q0,q1
alphabet: a_
blank: _
initial: q0
accept:

q0 a -> q1 a R
q0 a -> q0 a L
