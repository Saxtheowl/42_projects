# ft_strdup - Duplicate string
# char *ft_strdup(const char *s);
# Input: rdi = source string
# Output: rax = pointer to new string or NULL

.section .text
.globl ft_strdup
.type ft_strdup, @function

ft_strdup:
    pushq   %rbx
    pushq   %r12
    movq    %rdi, %r12          # save source string

    # Get length
    call    ft_strlen
    incq    %rax                # +1 for null terminator
    movq    %rax, %rbx          # save length

    # Allocate memory
    movq    %rax, %rdi
    call    malloc@PLT
    testq   %rax, %rax
    jz      .Ldone              # return NULL if malloc failed

    # Copy string
    movq    %rax, %rdi          # dst
    movq    %r12, %rsi          # src
    pushq   %rax                # save dst pointer
    call    ft_strcpy
    popq    %rax                # return dst pointer

.Ldone:
    popq    %r12
    popq    %rbx
    ret
