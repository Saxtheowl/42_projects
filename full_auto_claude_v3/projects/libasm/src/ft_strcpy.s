# ft_strcpy - Copy string
# char *ft_strcpy(char *dst, const char *src);
# Input: rdi = dst, rsi = src
# Output: rax = dst

.section .text
.globl ft_strcpy
.type ft_strcpy, @function

ft_strcpy:
    movq    %rdi, %rax          # save dst to return
    xorq    %rcx, %rcx          # index = 0
.Lloop:
    movb    (%rsi, %rcx), %dl
    movb    %dl, (%rdi, %rcx)
    testb   %dl, %dl            # check if null
    jz      .Ldone
    incq    %rcx
    jmp     .Lloop
.Ldone:
    ret
