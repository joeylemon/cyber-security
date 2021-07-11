# Root Exploitations in Vulnerable Program

This repository represents our group's working directory of the first lab in [COSC366: Introduction to Cybersecurity](https://catalog.utk.edu/preview_course_nopop.php?catoid=29&coid=154671) at the [University of Tennessee Knoxville](https://utk.edu/). The full lab write-up is under [Assignment.md](Assignment.md).

The goal of this lab was to find at least four ways to exploit a poorly-written and vulnerable program [bcvs](bcvs/bcvs.c) to escalate the privileges of the executing user to root within an instance of a shell such as /bin/sh. The exploits are runnable as shell scripts which set up the environment, run the bcvs program, and then clean up the aftermath. Our exploits ranged from exec abuse to buffer overflow.

Below are the detailed explanations of each exploit we discovered. Each of these exploits' write-ups and shell scripts are found under the [submit/](submit) directory.

## Exploit 1

### Mistakes that enabled this exploit
bcvs.c uses execlp() to run chown to set the student as the owner of the checked out file. The function execlp() uses the PATH variable to find the executable. However, anyone can modify their PATH variable, so anyone can overwrite chown with a custom executable.

### Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list and an empty file named test.txt. Then, we create a simple C program which calls setuid(0) and execl("/bin/sh"). We compile this file as fakebin/chown. Then, we add our fakebin directory to the beginning of the PATH variable. Next, we create an expect script which waits for bcvs to ask for input and enters "test" automatically (piping the input causes the exploit to break). Finally, we start the expect script which spawns bcvs with arguments to checkout the test.txt file. This causes bcvs to reach line 190 and call execlp("chown") which will execute our fakebin/chown program to start a root shell.

### Argument for distinctness
The simplest patch to prevent us from running a custom chown binary would be to change the execlp("chown") call on line 190 to the built-in chown function from <sys/stat.h> which doesn't use exec() at all.

This exploit is similar to exploit 2, which abuses bcvs's use of execlp("chmod") on line 204. However, since the simplest patch described above wouldn't change the execution of exploit 2, we believe they are two different vulnerabilities.

## Exploit 2

### Mistakes that enabled this exploit
bcvs.c uses execlp() to run chmod to change the permissions of the checked out file. The function execlp() uses the PATH variable to find the executable. However, anyone can modify their PATH variable, so anyone can overwrite chmod with a custom executable.

### Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list and an empty file named test.txt. Then, we create a simple C program which calls setuid(0) and execl("/bin/sh"). We compile this file as fakebin/chmod. Then, we add our fakebin directory to the beginning of the PATH variable. Next, we create an expect script which waits for bcvs to ask for input and enters "test" automatically (piping the input causes the exploit to break). Finally, we start the expect script which spawns bcvs with arguments to checkout the test.txt file. This causes bcvs to reach line 204 and call execlp("chmod") which will execute our fakebin/chmod program to start a root shell.

### Argument for distinctness
The simplest patch to prevent us from running a custom chmod binary would be to change the execlp("chmod") call on line 204 to the built-in chmod function from <sys/stat.h> which doesn't use exec() at all.

This exploit is similar to exploit 1, which abuses bcvs's use of execlp("chown") on line 190. However, since the simplest patch described above wouldn't change the execution of exploit 1, we believe they are two different vulnerabilities.

## Exploit 3

### Mistakes that enabled this exploit
Since bcvs runs as a privileged user, it is able to add users to the sudoers list. If supplied an empty block.list, the program will copy any file it is given. We abuse these facts to force bcvs to copy a file to the sudoers.d directory which allows the student user to run commands as root.

### Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list and a file named student which contains a sudoer definition for the student user. Then, we create a symbolic link from another file named student in the top-level directory to /etc/sudoers.d/student. Next, we run bcvs with arguments to checkout the top-level student file, which forces bcvs to copy the .bcvs/student file to ./student. Since ./student is actually the symlink to /etc/sudoers.d/student, bcvs inadvertently gives the student user sudo permissions. Finally, we run "sudo /bin/sh" which starts a shell as root.

### Argument for distinctness
The simplest patch to fix this exploit would be to change 
```
21:   #define BLOCK_LIST_PATH ".bcvs/block.list"
```
to
```
21:   #define BLOCK_LIST_PATH "/opt/bcvs/.bcvs/block.list"
```
Since bcvs uses a relative filepath for the block list, anyone can overwrite the block list which allows them to use bcvs to copy any file to any destination.

## Exploit 4

### Mistakes that enabled this exploit
bcvs.c uses strcpy() to form a filepath string from argv[2]. This filepath string variable "src" has a size of 72 bytes. Therefore, we can pass in enough bytes in argv[2] to overflow this buffer, overwrite the return address, and start executing our own code.

### Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list. Then, we compile an executable (named "fake") that calls setuid(0) and runs /bin/sh. Next, we run bcvs with the second argument as the output from python2 that contains our overflow. The overflow works as follows:

We create a NOP sled (\x90) of 148 instructions. Then, our shellcode contains 28 bytes of instructions which we created ourself with the following assembly:
```
xor rdi, rdi            ; Zero out the registers we'll be using
xor rsi, rsi
xor rdx, rdx
push rsi                ; Push NULL (0x0) onto the stack to signify end of argv array
mov rdi, 0x656b6166     ; Add "fake" as 1st argument (in reverse order)
push rdi                ; Push "fake" to stack
push rsp                ; Push stack pointer
pop rdi                 ; Pop stack pointer into 2nd argument (so *argv points to "fake")
xor rax, rax            ; Zero out the syscall number register
mov al,	59              ; Put 59 into register (sys_execve number)
cdq
push 0x2f               ; Add a random 2f ("/") byte so writeLog fails and skips user input
syscall                 ; Call execve
```
This assembly essentially calls execve("./fake", {"fake"}, NULL). We then added 40 bytes of padding so the input would start overwriting the return address, which we set to 0x7fffffffe8a0 which points to an instruction in our NOP sled. This argv[2] overflow adds up to 222 bytes. Once copyFile() returns, it goes to the instruction at 0x7fffffffe8a0, slides down the NOP sled, and executes our shellcode which in turn executes "fake". "fake" gives us the root shell with setuid(0) and execl("/bin/sh").

We tried different shellcodes that did the setuid(0) and exec("/bin/sh") calls within the instructions, but the spawned shell was never root. Therefore, we decided to make our own shellcode that would execute a separate binary with the same code.

### Argument for distinctness
The simplest patch to fix this would be to change strcpy() (line 151) to strncpy() with a max size for the buffer (in this case, a max size of 72 bytes).

This exploit has no similarity to any of the others in this directory. Therefore, we argue this exploit is completely unique and independent of any patch fixes for the other exploits.
