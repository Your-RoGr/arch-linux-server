#!/bin/bash

# Create backup
su git
./gogs backup --archive-name gogs-backup.zip
sudo docker cp extrolabs_gogs:/app/gogs/gogs-backup.zip ~/
