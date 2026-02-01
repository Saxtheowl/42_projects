# ft_write - Write to file descriptor
# ssize_t ft_write(int fd, const void *buf, size_t count);
# Input: rdi = fd, rsi = buf, rdx = count
# Output: rax = bytes written or -1 on error

.section .text
.globl ft_write
.type ft_write, @function

ft_write:
    movq    $1, %rax            # syscall number for write
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
