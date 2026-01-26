states: q0, qacc
alphabet: a,_
blank: __
initial: q0
accept: qacc
q0 a -> qacc a R
q0 _ -> qacc _ R
