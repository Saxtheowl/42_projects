# CPP Module 01

## Description

CPP Module 01 covers memory allocation, references, pointers to members, and file streams in C++.

## Exercises

### ex00 - BraiiiiiiinnnzzzZ
Zombie class demonstrating heap vs stack allocation:
- `newZombie`: Allocates zombie on heap (returns pointer, caller must delete)
- `randomChump`: Allocates zombie on stack (automatically destroyed)

### ex01 - Moar brainz!
Array allocation with `new[]` and `delete[]`:
- `zombieHorde`: Creates an array of N zombies with the same name

### ex02 - HI THIS IS BRAIN
Demonstrates pointers vs references:
- Shows that references and pointers to the same variable have the same address
- References are safer aliases to variables

### ex03 - Unnecessary violence
Weapon, HumanA, and HumanB classes:
- HumanA: Uses reference (weapon always exists)
- HumanB: Uses pointer (weapon can be NULL/set later)

### ex04 - Sed is for losers
File string replacement without using std::string::replace:
- Reads file, replaces all occurrences of s1 with s2
- Writes to filename.replace

### ex05 - Harl 2.0
Pointers to member functions:
- Uses array of function pointers to call appropriate complaint level
- Demonstrates member function pointer syntax

### ex06 - Harl filter
Switch statement with fall-through:
- Filters complaints by level (DEBUG shows all, ERROR shows only ERROR)
- Uses switch without break for cascade effect

## Compilation

```bash
# Compile each exercise
cd ex00 && make
cd ex01 && make
# etc.
```

## Usage

```bash
# ex00
./zombie

# ex01
./zombieHorde

# ex02
./brain

# ex03
./violence

# ex04
echo "Hello World" > test.txt
./replace test.txt World Universe
cat test.txt.replace

# ex05
./harl

# ex06
./harlFilter WARNING
```

## Author

Implementation for 42 curriculum.
