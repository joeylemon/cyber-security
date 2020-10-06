Exploit 3

## Mistakes that enabled this exploit
Since bcvs runs as a privileged user, it is able to add users to the sudoers list. If supplied an empty block.list, the program will copy any file it is given. We abuse these facts to force bcvs to copy a file to the sudoers.d directory which allows the student user to run commands as root.

## How we constructed our inputs
We created a bash script to generate our helper files and directories and create a symlink to the sudoers.d directory.

## Step-by-step explanation of exploit
First, we initialize the bcvs repository with an empty block.list and a file named student which contains a sudoer definition for the student user. Then, we create a symbolic link from another file named student in the top-level directory to /etc/sudoers.d/student. Next, we run bcvs with arguments to checkout the top-level student file, which forces bcvs to copy the .bcvs/student file to ./student. Since ./student is actually the symlink to /etc/sudoers.d/student, bcvs inadvertently gives the student user sudo permissions. Finally, we run "sudo /bin/sh" which starts a shell as root.

## Argument for distinctness
The simplest patch to fix this exploit would be to change 
21:   #define BLOCK_LIST_PATH ".bcvs/block.list"
to
21:   #define BLOCK_LIST_PATH "/opt/bcvs/.bcvs/block.list"
Since bcvs uses a relative filepath for the block list, anyone can overwrite the block list which allows them to use bcvs to copy any file to any destination.

This exploit has no similarity to any of the others in this directory. Therefore, we argue this exploit is completely unique and independent of any patch fixes for the other exploits.
