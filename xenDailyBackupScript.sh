#!/bin/bash
DATE=`date +%Y%m%d`
XSNAME=`echo $HOSTNAME`

#Get the day of the week
DOW=$(date +%u)

if [ $DOW = 1 ]; then
   UUIDFILE=/tmp/xenVMBackupsMonday.txt
fi

if [ $DOW = 2 ]; then
   UUIDFILE=/tmp/xenVMBackupsTuesday.txt
fi

if [ $DOW = 3 ]; then
   UUIDFILE=/tmp/xenVMBackupsWednesday.txt
fi

if [ $DOW = 4 ]; then
   UUIDFILE=/tmp/xenVMBackupsThursday.txt
fi

if [ $DOW = 5 ]; then
   UUIDFILE=/tmp/xenVMBackupsFriday.txt
fi

if [ $DOW = 6 ]; then
   exit 1
fi

if [ $DOW = 7 ]; then
   exit 1
fi

BACKUPPATH=/mnt/$XSNAME/$DATE
mkdir -p $BACKUPPATH
if [ ! -d $BACKUPPATH ]; then
 echo "No backup directory found"; exit 0
fi

# Quit if we can't find the file
if [ ! -f "$UUIDFILE" ]; then
 echo "No UUID list file found"; exit 0
fi

# Loop through VMs, take snapshots, convert the VMs to .xva
# Export to mounted storage, delete the snapshot from the xenserver
while read VMUUID; do
 VMNAME=`xe vm-list uuid=$VMUUID | grep name-label | cut -d":" -f2 | sed 's/^ *//g'`
 SNAPUUID=`xe vm-snapshot uuid=$VMUUID new-name-label="SNAPSHOT-$VMUUID-$DATE"`
 xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAPUUID
 xe vm-export vm=$SNAPUUID filename="$BACKUPPATH/$VMNAME-$DATE.xva"
 xe vm-uninstall uuid=$SNAPUUID force=true
done < $UUIDFILE

