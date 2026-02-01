; libftasm2 - Extended Assembly Library
; Additional assembly functions for libftasm
;
; Build: nasm -f elf64 libftasm2.s -o libftasm2.o
;        ar rcs libftasm2.a libftasm2.o

section .data
    hex_chars db "0123456789abcdef"

section .bss

section .text

; ============================================================
; void *ft_memset(void *s, int c, size_t n)
; ============================================================
global ft_memset
ft_memset:
    push rbx
    mov rax, rdi        ; Save return value (pointer)
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

    mov al, sil         ; Character to set

    ; Use rep stosb for simplicity
    mov rdi, rdi        ; Destination already in rdi
    mov al, sil         ; Character
    rep stosb

    ; Restore return value
    mov rax, [rsp+8]    ; Original rdi
.done:
    pop rbx
    ret

; ============================================================
; void *ft_memcpy(void *dest, const void *src, size_t n)
; ============================================================
global ft_memcpy
ft_memcpy:
    mov rax, rdi        ; Return dest
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

    rep movsb           ; Copy bytes
.done:
    ret

; ============================================================
; void *ft_memmove(void *dest, const void *src, size_t n)
; ============================================================
global ft_memmove
ft_memmove:
    mov rax, rdi        ; Return dest
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

    ; Check for overlap
    cmp rdi, rsi
    je .done            ; Same address, nothing to do
    jb .forward         ; dest < src, copy forward

    ; dest > src, copy backward
    lea rdi, [rdi + rcx - 1]
    lea rsi, [rsi + rcx - 1]
    std                 ; Set direction flag (backward)
    rep movsb
    cld                 ; Clear direction flag
    jmp .done

.forward:
    rep movsb
.done:
    ret

; ============================================================
; int ft_memcmp(const void *s1, const void *s2, size_t n)
; ============================================================
global ft_memcmp
ft_memcmp:
    xor eax, eax        ; Clear return value
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

    repe cmpsb          ; Compare bytes
    je .done            ; Equal

    ; Not equal - get difference
    movzx eax, byte [rdi-1]
    movzx ecx, byte [rsi-1]
    sub eax, ecx
.done:
    ret

; ============================================================
; void *ft_memchr(const void *s, int c, size_t n)
; ============================================================
global ft_memchr
ft_memchr:
    mov rcx, rdx        ; Count
    mov al, sil         ; Character to find
    test rcx, rcx
    jz .not_found

    repne scasb         ; Scan for character
    jne .not_found

    lea rax, [rdi-1]    ; Found - return pointer
    ret

.not_found:
    xor eax, eax        ; Return NULL
    ret

; ============================================================
; size_t ft_strnlen(const char *s, size_t maxlen)
; ============================================================
global ft_strnlen
ft_strnlen:
    mov rcx, rsi        ; maxlen
    mov rax, rdi        ; Save start
    test rcx, rcx
    jz .done_zero

    xor al, al          ; Look for null
    repne scasb

    ; Calculate length
    mov rax, rdi
    sub rax, [rsp-8]    ; Current - original
    dec rax             ; Don't count null

    ; Check if we found null or hit limit
    cmp rax, rsi
    jbe .return
    mov rax, rsi        ; Return maxlen
.return:
    ret

.done_zero:
    xor eax, eax
    ret

; ============================================================
; char *ft_strncpy(char *dest, const char *src, size_t n)
; ============================================================
global ft_strncpy
ft_strncpy:
    push rbx
    mov rax, rdi        ; Return dest
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

.copy_loop:
    lodsb               ; Load from src
    stosb               ; Store to dest
    test al, al
    jz .pad             ; Hit null, pad rest
    dec rcx
    jnz .copy_loop
    jmp .done

.pad:
    dec rcx
    jz .done
    xor al, al
    rep stosb           ; Fill rest with nulls

.done:
    pop rbx
    ret

; ============================================================
; int ft_strncmp(const char *s1, const char *s2, size_t n)
; ============================================================
global ft_strncmp
ft_strncmp:
    xor eax, eax        ; Clear return
    mov rcx, rdx        ; Count
    test rcx, rcx
    jz .done

.loop:
    mov al, [rdi]
    mov bl, [rsi]
    cmp al, bl
    jne .diff
    test al, al         ; Check for null
    jz .done
    inc rdi
    inc rsi
    dec rcx
    jnz .loop
    xor eax, eax
    jmp .done

.diff:
    movzx eax, al
    movzx ecx, bl
    sub eax, ecx
.done:
    ret

; ============================================================
; char *ft_strchr(const char *s, int c)
; ============================================================
global ft_strchr
ft_strchr:
    mov al, sil         ; Character to find

.loop:
    mov cl, [rdi]
    cmp cl, al
    je .found
    test cl, cl
    jz .not_found
    inc rdi
    jmp .loop

.found:
    mov rax, rdi
    ret

.not_found:
    ; Check if looking for null terminator
    test al, al
    jnz .null
    mov rax, rdi
    ret
.null:
    xor eax, eax
    ret

; ============================================================
; char *ft_strrchr(const char *s, int c)
; ============================================================
global ft_strrchr
ft_strrchr:
    xor eax, eax        ; Last found = NULL
    mov cl, sil         ; Character to find

.loop:
    mov dl, [rdi]
    cmp dl, cl
    jne .next
    mov rax, rdi        ; Remember this position
.next:
    test dl, dl
    jz .done
    inc rdi
    jmp .loop

.done:
    ret

; ============================================================
; int ft_toupper(int c)
; ============================================================
global ft_toupper
ft_toupper:
    mov eax, edi
    cmp eax, 'a'
    jb .done
    cmp eax, 'z'
    ja .done
    sub eax, 32         ; Convert to uppercase
.done:
    ret

; ============================================================
; int ft_tolower(int c)
; ============================================================
global ft_tolower
ft_tolower:
    mov eax, edi
    cmp eax, 'A'
    jb .done
    cmp eax, 'Z'
    ja .done
    add eax, 32         ; Convert to lowercase
.done:
    ret

; ============================================================
; int ft_isprint(int c)
; ============================================================
global ft_isprint
ft_isprint:
    xor eax, eax
    cmp edi, 32
    jb .done
    cmp edi, 126
    ja .done
    mov eax, 1
.done:
    ret

; ============================================================
; int ft_isspace(int c)
; ============================================================
global ft_isspace
ft_isspace:
    xor eax, eax
    cmp edi, ' '
    je .yes
    cmp edi, 9          ; Tab
    jb .done
    cmp edi, 13         ; CR
    ja .done
.yes:
    mov eax, 1
.done:
    ret

; ============================================================
; int ft_abs(int n)
; ============================================================
global ft_abs
ft_abs:
    mov eax, edi
    cdq                 ; Sign extend to edx
    xor eax, edx        ; Flip bits if negative
    sub eax, edx        ; Add 1 if was negative
    ret

; ============================================================
; void ft_bzero(void *s, size_t n)
; ============================================================
global ft_bzero
ft_bzero:
    mov rcx, rsi        ; Count
    xor al, al          ; Zero byte
    rep stosb
    ret

; ============================================================
; void ft_swap(int *a, int *b)
; ============================================================
global ft_swap
ft_swap:
    mov eax, [rdi]
    mov ecx, [rsi]
    mov [rdi], ecx
    mov [rsi], eax
    ret

; ============================================================
; int ft_atoi(const char *str)
; ============================================================
global ft_atoi
ft_atoi:
    xor eax, eax        ; Result
    xor ecx, ecx        ; Sign (0 = positive)

    ; Skip whitespace
.skip_space:
    movzx edx, byte [rdi]
    cmp dl, ' '
    je .next_space
    cmp dl, 9
    jb .check_sign
    cmp dl, 13
    ja .check_sign
.next_space:
    inc rdi
    jmp .skip_space

.check_sign:
    cmp dl, '-'
    je .negative
    cmp dl, '+'
    jne .parse
    inc rdi
    jmp .parse

.negative:
    mov ecx, 1
    inc rdi

.parse:
    movzx edx, byte [rdi]
    sub edx, '0'
    cmp edx, 9
    ja .apply_sign

    imul eax, 10
    add eax, edx
    inc rdi
    jmp .parse

.apply_sign:
    test ecx, ecx
    jz .done
    neg eax
.done:
    ret
