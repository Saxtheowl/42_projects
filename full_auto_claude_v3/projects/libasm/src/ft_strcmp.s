# ft_strcmp - Compare strings
# int ft_strcmp(const char *s1, const char *s2);
# Input: rdi = s1, rsi = s2
# Output: rax = difference or 0 if equal

.section .text
.globl ft_strcmp
.type ft_strcmp, @function

ft_strcmp:
    xorq    %rcx, %rcx
.Lloop:
    movzbl  (%rdi, %rcx), %eax   # get s1[i]
    movzbl  (%rsi, %rcx), %edx   # get s2[i]
    cmpl    %edx, %eax
    jne     .Ldiff
    testl   %eax, %eax           # check for null terminator
    jz      .Lequal
    incq    %rcx
    jmp     .Lloop
.Ldiff:
    subl    %edx, %eax
    ret
.Lequal:
    xorl    %eax, %eax
    ret
