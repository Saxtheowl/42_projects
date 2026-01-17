# Invalid: transition points to unknown state q2
states: q0,q1,qacc
alphabet: a_
blank: _
initial: q0
accept: qacc

q0 a -> q2 a R
