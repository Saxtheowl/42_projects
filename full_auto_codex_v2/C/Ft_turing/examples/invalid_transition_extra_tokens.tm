# Invalid: extra tokens on a transition line
states: q0,qacc
alphabet: a_
blank: _
initial: q0
accept: qacc

q0 a -> qacc a R extra
