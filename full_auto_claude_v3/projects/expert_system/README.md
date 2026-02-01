# Expert System

A propositional logic inference engine using backward chaining.

## Description

This expert system evaluates logical queries based on a set of rules and initial facts. It uses backward chaining to determine whether queried propositions are true or false.

## Features

- Backward chaining inference
- Propositional logic operators (AND, OR, XOR, NOT)
- Implication (=>) and equivalence (<=>) rules
- Parentheses for grouping
- Circular dependency detection
- Memoization for efficiency

## Usage

```bash
chmod +x expert_system.py
./expert_system.py input_file.txt
```

## Input File Format

```
# Comments start with #

# Rules: use => for implication, <=> for equivalence
A + B => C          # A AND B implies C
A | B => D          # A OR B implies D
A ^ B => E          # A XOR B implies E
!A => F             # NOT A implies F
(A + B) | C => D    # Parentheses for grouping

# Initial facts (line starting with =)
=AB                 # A and B are true

# Queries (line starting with ?)
?CDE                # Query: C, D, E
```

## Operators

| Symbol | Operator | Description |
|--------|----------|-------------|
| `+` | AND | Both operands must be true |
| `\|` | OR | At least one operand must be true |
| `^` | XOR | Exactly one operand must be true |
| `!` | NOT | Negation |
| `=>` | IMPLIES | If left is true, right is true |
| `<=>` | IFF | Both sides have same truth value |
| `()` | PAREN | Grouping |

## Operator Precedence (highest to lowest)

1. `()` - Parentheses
2. `!` - NOT
3. `+` - AND
4. `^` - XOR
5. `|` - OR

## Example

Input file (`example.txt`):
```
# If it's a mammal and has fur, it's probably warm-blooded
M + F => W

# If it's a bird, it can fly (usually)
B => Y

# A cat is a mammal with fur
C => M + F

=C    # We know it's a cat
?WY   # Is it warm-blooded? Can it fly?
```

Output:
```
Initial facts: C
Queries: W Y
Rules: 3

Results:
  W = true
  Y = false
```

## Algorithm

### Backward Chaining
1. Start with the query fact
2. Look for rules whose conclusion contains the query
3. Evaluate the condition of matching rules
4. Recursively evaluate any facts in the condition
5. If any rule's condition is true, the query is true

### Memoization
- Results of evaluated facts are cached
- Prevents redundant computation
- Handles circular dependencies

## Files

| File | Description |
|------|-------------|
| `expert_system.py` | Main inference engine |
| `test1.txt` | Example test file |
| `README.md` | Documentation |

## Test Cases

### Test 1: Basic AND
```
A + B => C
=AB
?C
```
Result: C = true

### Test 2: OR with partial facts
```
A | B => C
=A
?C
```
Result: C = true

### Test 3: NOT
```
!A => B
=
?B
```
Result: B = true (A is false, so !A is true)

### Test 4: Equivalence
```
A <=> B
=A
?B
```
Result: B = true

## Limitations

- Only single uppercase letters for fact names
- No nested implications in conclusions
- No probabilistic reasoning

## Author

Implementation for 42 curriculum.
