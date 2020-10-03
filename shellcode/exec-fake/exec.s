global _start

section .text

_start:
	;int execve(const char *filename, char *const argv[],char *const envp[])
	;	    rdi		  	  rsi		     rdx
	xor	rdi,	rdi
	xor 	rsi,	rsi
	xor	rdx,	rdx
	push	rsi				;push null on the stack
	mov 	rdi,	0x656b6166		;fake in reverse order
	push	rdi				;push fake onto stack
	push	rsp				;push stack pointer so argv[0] points to fake
	pop	rdi				;remove fake from stack
	;mov	rsi,	rs
	xor	rax,	rax			;set rax to 0p
	mov 	al,	59			;sys_execve
	cdq					;sign extend of eax
	push	0x2f
	syscall
