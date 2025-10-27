section .text
global ft_strcpy

ft_strcpy:
    mov rax, rdi
.copy_loop:
    mov dl, [rsi]
    mov [rdi], dl
    inc rsi
    inc rdi
    test dl, dl
    jne .copy_loop
    ret
