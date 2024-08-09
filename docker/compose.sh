#!/bin/bash

sudo mkdir -p /mnt/raid0/etc/letsencryp
sudo mkdir -p /mnt/raid0/var/lib/letsencrypt
sudo mkdir -p /mnt/raid0/var/lib/postgresql/data
sudo mkdir -p /mnt/raid0/var/gogs
sudo mkdir -p /mnt/raid0/var/www/certbot

sudo chown -R $USER /mnt/raid0/etc/letsencryp
sudo chown -R $USER /mnt/raid0/var/lib/letsencrypt
sudo chown -R $USER /mnt/raid0/var/lib/postgresql/data
sudo chown -R $USER /mnt/raid0/var/gogs
sudo chown -R $USER /mnt/raid0/var/www/certbot

cd "$(dirname $0)"
sudo mkdir -p ./nginx
sudo touch ./nginx/error.log
sudo touch ./nginx/access.log
sudo docker compose up -d --build
