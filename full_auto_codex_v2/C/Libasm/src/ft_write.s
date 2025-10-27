section .text
global ft_write
extern __errno_location

ft_write:
    mov rax, 1
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
