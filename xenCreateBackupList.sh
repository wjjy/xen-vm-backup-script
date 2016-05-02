#!/bin/bash
cp /dev/null /tmp/uuids.txt
cp /dev/null /tmp/xenVMBackupsMonday.txt
cp /dev/null /tmp/xenVMBackupsTuesday.txt
cp /dev/null /tmp/xenVMBackupsWednesday.txt
cp /dev/null /tmp/xenVMBackupsThursday.txt
cp /dev/null /tmp/xenVMBackupsFriday.txt

UUIDFILE=/tmp/uuids.txt

XENSERVER=`cat /etc/xensource-inventory | grep -i installation_uuid | cut -d"=" -f2 | cut -d "'" -f 2`

# Fetching list UUIDs of all VMs running on XenServer
# May want to validate that xe vm-list output is
# in the correct format, in case it changes in the future
xe vm-list resident-on=$XENSERVER is-control-domain=false is-a-snapshot=false | grep uuid | cut -d":" -f2 > $UUIDFILE

k=1
while read VMUUID; do
 mod=$((k%5))
 if [ $mod = 0 ]; then
        echo $VMUUID >> /tmp/xenVMBackupsMonday.txt
 fi
 if [ $mod = 1 ]; then
        echo $VMUUID >> /tmp/xenVMBackupsTuesday.txt
 fi
 if [ $mod = 2 ]; then
        echo $VMUUID >> /tmp/xenVMBackupsWednesday.txt
 fi
 if [ $mod = 3 ]; then
        echo $VMUUID >> /tmp/xenVMBackupsThursday.txt
 fi
 if [ $mod = 4 ]; then
        echo $VMUUID >> /tmp/xenVMBackupsFriday.txt
 fi
 k=$((k+1))
done < $UUIDFILE
