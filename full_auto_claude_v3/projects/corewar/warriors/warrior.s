.name "Warrior"
.comment "Attack and survive"

start:
    live %1
loop:
    fork %:loop
    zjmp %:start
