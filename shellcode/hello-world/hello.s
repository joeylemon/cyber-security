global _start
section .text
_start:
    ; Zero out rax, move 1 into it (sys_write call number)
    xor rax, rax
    mov al, 0x1

    ; Zero out rdi, move 1 into it (stdout)
    xor rdi, rdi
    mov dil, 0x1
    
    ; Zero out rdx, move 12 into it (length of string)
    xor rdx, rdx
    mov dl, 20
    
    ; Push "Hello World\n" onto the stack in reverse order
    ; ;dlr
    push 0x3b646c72
    ; oW_o
    push 0x6f575f6f
    ; lleH
    push 0x6c6c6548
    
    ; Put address of stack (start address of our string) into rsi
    mov rsi, rsp
    
    syscall

    ; Exit with 0 status
    mov al, 60    ; sys_exit
    xor rdi, rdi  ; zero out rdi (0 status)
    syscall
