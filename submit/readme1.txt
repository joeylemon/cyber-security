Exploit 1

## Mistakes that enabled this exploit
bcvs.c uses execlp() to run chown to set the student as the owner of the checked out file. The function execlp() uses the PATH variable to find the executable. However, anyone can modify their PATH variable, so anyone can overwrite chown with a custom executable.

## How we constructed our inputs
We created a bash script to generate our helper files and directories and compile our fake binary. We also created an expect script which automatically gives input to the bcvs program.

## Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list and an empty file named test.txt. Then, we create a simple C program which calls setuid(0) and execl("/bin/sh"). We compile this file as fakebin/chown. Then, we add our fakebin directory to the beginning of the PATH variable. Next, we create an expect script which waits for bcvs to ask for input and enters "test" automatically (piping the input causes the exploit to break). Finally, we start the expect script which spawns bcvs with arguments to checkout the test.txt file. This causes bcvs to reach line 190 and call execlp("chown") which will execute our fakebin/chown program to start a root shell.

## Argument for distinctness
The simplest patch to prevent us from running a custom chown binary would be to change the execlp("chown") call on line 190 to the built-in chown function from <sys/stat.h> which doesn't use exec() at all.

This exploit is similar to exploit 2, which abuses bcvs's use of execlp("chmod") on line 204. However, since the simplest patch described above wouldn't change the execution of exploit 2, we believe they are two different vulnerabilities.
