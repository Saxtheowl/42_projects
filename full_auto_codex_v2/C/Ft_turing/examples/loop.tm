# Infinite loop unless stopped by max_steps
states: q0
alphabet: a_
blank: _
initial: q0
accept: 

q0 a -> q0 a R
q0 _ -> q0 _ R
