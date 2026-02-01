# ft_strlen - Calculate string length
# size_t ft_strlen(const char *s);
# Input: rdi = pointer to string
# Output: rax = length of string

.section .text
.globl ft_strlen
.type ft_strlen, @function

ft_strlen:
    xorq    %rax, %rax          # counter = 0
.Lloop:
    cmpb    $0, (%rdi, %rax)    # check if null terminator
    je      .Ldone
    incq    %rax
    jmp     .Lloop
.Ldone:
    ret
