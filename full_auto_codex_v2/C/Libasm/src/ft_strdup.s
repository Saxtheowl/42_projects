section .text
global ft_strdup
extern malloc
extern ft_strlen
extern ft_strcpy

ft_strdup:
    test rdi, rdi
    je .null_input
    sub rsp, 8
    mov [rsp], rdi
    call ft_strlen
    inc rax
    mov rdi, rax
    call malloc
    test rax, rax
    je .malloc_fail
    mov rsi, [rsp]
    mov rdi, rax
    call ft_strcpy
    add rsp, 8
    ret
.malloc_fail:
    add rsp, 8
    ret
.null_input:
    xor eax, eax
    ret
