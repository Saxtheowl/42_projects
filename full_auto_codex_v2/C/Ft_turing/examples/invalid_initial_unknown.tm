states: q0, qacc
alphabet: a,_
blank: _
initial: q1
accept: qacc
q0 a -> qacc a R
q0 _ -> qacc _ R
