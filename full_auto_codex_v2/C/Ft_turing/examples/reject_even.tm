# Reject if input length is even (over alphabet a)
states: q0,q1,qacc,qrej
alphabet: a_
blank: _
initial: q0
accept: qacc

# flip parity on each a
q0 a -> q1 a R
q1 a -> q0 a R
# end of tape -> decide
q0 _ -> qrej _ R
q1 _ -> qacc _ R
