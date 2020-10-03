NAME=exec

build:
	# --32
	# -m elf_i386
	nasm -f elf64 -o $(NAME).o $(NAME).s
	ld $(NAME).o -o $(NAME)

code:
	objdump -d ./exec|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
