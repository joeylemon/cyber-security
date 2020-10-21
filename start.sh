qemu-system-x86_64 \
-hda "/Users/joeylemon/Desktop/lab1/old-vm.qcow2" \
-m 2G \
-net user,hostfwd=tcp::2222-:22 \
-net nic &
