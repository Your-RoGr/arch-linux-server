#!/bin/bash

sudo mkdir -p /mnt/raid0/etc/letsencryp
sudo mkdir -p /mnt/raid0/var/lib/letsencrypt
sudo mkdir -p /mnt/raid0/extrolabs-db-data
sudo mkdir -p /mnt/raid0/var/gogs

sudo chown -R $USER /mnt/raid0/etc/letsencryp
sudo chown -R $USER /mnt/raid0/var/lib/letsencrypt
sudo chown -R $USER /mnt/raid0/extrolabs-db-data
sudo chown -R $USER /mnt/raid0/var/gogs

cd "$(dirname $0)"
sudo mkdir -p ./nginx
sudo touch ./nginx/error.log
sudo touch ./nginx/access.log
sudo docker compose up -d --build
