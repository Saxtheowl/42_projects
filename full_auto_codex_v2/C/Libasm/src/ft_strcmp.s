section .text
global ft_strcmp

ft_strcmp:
.loop:
    movzx eax, byte [rdi]
    movzx ecx, byte [rsi]
    cmp eax, ecx
    jne .diff
    test eax, eax
    je .equal
    inc rdi
    inc rsi
    jmp .loop
.diff:
    sub eax, ecx
    ret
.equal:
    xor eax, eax
    ret
