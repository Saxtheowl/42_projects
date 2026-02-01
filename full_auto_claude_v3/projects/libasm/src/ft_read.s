# ft_read - Read from file descriptor
# ssize_t ft_read(int fd, void *buf, size_t count);
# Input: rdi = fd, rsi = buf, rdx = count
# Output: rax = bytes read or -1 on error

.section .text
.globl ft_read
.type ft_read, @function

ft_read:
    movq    $0, %rax            # syscall number for read
    syscall
    cmpq    $0, %rax
    jl      .Lerror
    ret
.Lerror:
    negq    %rax                # make positive error code
    pushq   %rax                # save error code
    call    __errno_location@PLT
    popq    %rdx                # get error code
    movl    %edx, (%rax)        # store errno
    movq    $-1, %rax
    ret
