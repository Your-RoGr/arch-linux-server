#!/bin/bash

sudo fdisk -l
lsblk
echo "Enter the number of devices for RAID 1 (minimum 2):"
read num_devices

if [ "$num_devices" -lt 2 ]; then
    echo "Error: Number of devices must be at least 2 for RAID 1."
    exit 1
fi

echo "Enter the device $num_devices paths for the RAID 1 array (e.g. /dev/sdb [send] /dev/sdc):"
devices=()
for i in $(seq 1 "$num_devices"); do
    read device
    devices+=" $device"
    if [ -b "$device" ]; then
        devices+=("$device")
    else
        echo "Error: Invalid device path '$device'. Please enter a valid block device path."
        exit 1
    fi
done

highest_number=$(sudo mdadm --detail --scan | grep -o '/dev/md[0-9]*' | sed 's/\/dev\/md//' | sort -n | tail -1)

if [ -z "$highest_number" ]; then
    free_number=0
else
    free_number=$((highest_number + 1))
fi

sudo mdadm --create /dev/md$free_number --level=1 --raid-devices=$num_devices $devices
sudo mkfs.ext4 /dev/md$free_number
sudo mkdir /mnt/raid$free_number
sudo mount /dev/md$free_number /mnt/raid$free_number
echo '/dev/md'$free_number' /mnt/raid'$free_number' auto defaults 0 2' | sudo tee -a /etc/fstab
sudo mdadm --detail /dev/md$free_number
