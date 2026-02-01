# little_penguin - Linux Kernel Module

Educational Linux kernel module development project.

## Note

This project requires:
- Linux kernel headers
- Root/sudo access
- Development environment for kernel modules

The exercises below demonstrate kernel module concepts.

## Exercises Overview

### Exercise 01: Hello World Module
```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("42");
MODULE_DESCRIPTION("Hello World");

static int __init hello_init(void) {
    printk(KERN_INFO "Hello World!\n");
    return 0;
}

static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye!\n");
}

module_init(hello_init);
module_exit(hello_exit);
```

### Exercise 02: USB Keyboard Module
Identify USB keyboard and print info on connect/disconnect.

### Exercise 03: /proc Entry
Create /proc/id file returning "42 login".

### Exercise 04: /sys Entry
Create sysfs entry with read/write.

### Exercise 05: Misc Device
Create misc device with specific behavior.

### Exercise 06: Debugfs
Create debugfs entries for debugging.

### Exercise 07: List Mounts
List all mounted filesystems.

### Exercise 08: Memory Manipulation
Safely manipulate kernel memory.

## Building Modules

```makefile
obj-m += hello.o

all:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules

clean:
    make -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean
```

## Loading/Unloading

```bash
sudo insmod hello.ko  # Load
lsmod | grep hello    # Check
dmesg | tail          # View logs
sudo rmmod hello      # Unload
```

## Key Concepts

- `printk()` - Kernel logging
- `module_init()` / `module_exit()` - Entry points
- `MODULE_LICENSE()` - License declaration
- `/proc` filesystem - Process info
- `/sys` filesystem - Device attributes
- `debugfs` - Debug filesystem

## Author

Implementation guide for 42 curriculum.
