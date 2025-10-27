section .text
global ft_read
extern __errno_location

ft_read:
    xor rax, rax
    syscall
    cmp rax, 0
    jge .success
    neg rax
    mov edi, eax
    call __errno_location
    mov [rax], edi
    mov eax, -1
    ret
.success:
    ret
