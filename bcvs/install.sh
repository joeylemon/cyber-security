#!/bin/bash
EXE="bcvs"
EXEDIR='/opt/'$EXE
EXEPATH=$EXEDIR'/'$EXE
DATADIR=$EXEDIR'/.'$EXE
BLOCKLIST="block.list"
BLOCKLISTPATH=$DATADIR'/'$BLOCKLIST

gcc -fno-stack-protector -z execstack ${EXE}.c -o ${EXE}

#echo "The installer now needs root permission"

#directory structure
#sudo mkdir /opt
sudo mkdir $EXEDIR
sudo chmod 777 $EXEDIR
sudo mkdir $DATADIR
sudo chmod go-rwx $DATADIR

#EXE
sudo mv $EXE $EXEDIR
sudo chown root:root $EXEPATH
sudo chmod a+rx $EXEPATH
sudo chmod a+s $EXEPATH

#blocklist
sudo echo $BLOCKLISTPATH > $BLOCKLIST
sudo echo "/etc/" >> $BLOCKLIST
sudo echo "/etc/shadow" >> $BLOCKLIST
sudo echo "/sbin/" >> $BLOCKLIST
sudo mv $BLOCKLIST $BLOCKLISTPATH
sudo chown root:root $BLOCKLISTPATH
sudo chmod go-rwx $BLOCKLISTPATH

#files
sudo mv ${EXE}.c $DATADIR'/'${EXE}.c
sudo chown root:root $DATADIR'/'${EXE}.c
sudo chmod go-rwx $DATADIR'/'${EXE}.c

#done
echo "Done!"
