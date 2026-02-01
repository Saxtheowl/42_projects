# libunit - Unit Testing Library for C

Simple unit testing framework for C projects.

## Features

- Test suites and test cases
- Multiple assertion types
- Crash handling (forks tests)
- Colored output
- Summary report

## Building

```bash
make        # Build library
make demo   # Build and run demo
```

## Usage

```c
#include "libunit.h"

int test_addition(void) {
    ASSERT_EQ(4, 2 + 2);
    return TEST_SUCCESS;
}

int main(void) {
    t_suite *suite = ut_create_suite("Math");
    ut_add_test(suite, "addition", test_addition);

    int result = ut_run_all();
    ut_cleanup();
    return result;
}
```

## Assertions

| Macro | Description |
|-------|-------------|
| `ASSERT(cond)` | Assert condition is true |
| `ASSERT_EQ(exp, act)` | Assert integers equal |
| `ASSERT_STR_EQ(exp, act)` | Assert strings equal |
| `ASSERT_NULL(ptr)` | Assert pointer is NULL |
| `ASSERT_NOT_NULL(ptr)` | Assert pointer is not NULL |

## Return Codes

- `TEST_SUCCESS` (0) - Test passed
- `TEST_FAILURE` (1) - Test failed
- `TEST_TIMEOUT` (2) - Test timed out
- `TEST_SIGNAL` (3) - Test crashed

## Author

Implementation for 42 curriculum.
