Exploit 4

## Mistakes that enabled this exploit
bcvs.c uses strcpy() to form a filepath string from argv[2]. This filepath string variable "src" has a size of 72 bytes. Therefore, we can pass in enough bytes in argv[2] to overflow this buffer, overwrite the return address, and start executing our own code.

## How we constructed our inputs
We created a bash script to generate our helper files and directories, including an executable that calls setuid(0) and runs /bin/sh. This script also calls python to generate our overflow for argv[2].

## Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list. Then, we compile an executable (named "fake") that calls setuid(0) and runs /bin/sh. Next, we run bcvs with the second argument as the output from python2 that contains our overflow. The overflow works as follows:

We create a NOP sled (\x90) of 148 instructions. Then, our shellcode contains 28 bytes of instructions which we created ourself with the following assembly:
	xor	rdi, rdi            ; Zero out the registers we'll be using
	xor rsi, rsi
	xor	rdx, rdx
	push rsi                ; Push NULL (0x0) onto the stack to signify end of argv array
	mov rdi, 0x656b6166     ; Add "fake" as 1st argument (in reverse order)
	push rdi                ; Push "fake" to stack
	push rsp                ; Push stack pointer
	pop	rdi                 ; Pop stack pointer into 2nd argument (so *argv points to "fake")
	xor	rax, rax            ; Zero out the syscall number register
	mov al,	59              ; Put 59 into register (sys_execve number)
	cdq
	push 0x2f               ; Add a random 2f ("/") byte so writeLog fails and skips user input
	syscall                 ; Call execve
This assembly essentially calls execve("./fake", {"fake"}, NULL). We then added 40 bytes of padding so the input would start overwriting the return address, which we set to 0x7fffffffe8a0 which points to an instruction in our NOP sled. This argv[2] overflow adds up to 222 bytes. Once copyFile() returns, it goes to the instruction at 0x7fffffffe8a0, slides down the NOP sled, and executes our shellcode which in turn executes "fake". "fake" gives us the root shell with setuid(0) and execl("/bin/sh").

We tried different shellcodes that did the setuid(0) and exec("/bin/sh") calls within the instructions, but the spawned shell was never root. Therefore, we decided to make our own shellcode that would execute a separate binary with the same code.

## Argument for distinctness
The simplest patch to fix this would be to change strcpy() (line 151) to strncpy() with a max size for the buffer (in this case, a max size of 72 bytes).

This exploit has no similarity to any of the others in this directory. Therefore, we argue this exploit is completely unique and independent of any patch fixes for the other exploits.
