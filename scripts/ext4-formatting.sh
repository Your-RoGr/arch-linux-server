#!/bin/bash

lsblk
echo "Enter your disk:"
read sd
sd=$(echo $sd | sed 's/[^[:alnum:]\/_:]//g')
echo "You entered: $sd"

if [[ "${sd:0:2}" == "sd" ]]; then
    sudo mkfs.ext4 /dev/"$sd"
    sudo blkid /dev/"$sd"
else
    echo "Incorrect format"
fi
