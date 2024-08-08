#!/bin/bash

echo "Enter your raid or send nothing for use root (example: /mnt/raid0):"
read path
path=$(echo $path | sed 's/[^[:alnum:]\/_:]//g')
echo "You entered: $path"

cd "$(dirname $0)"
sudo mkdir -p ./nginx
sudo touch ./nginx/error.log
sudo touch ./nginx/access.log
sudo docker compose up -d --build
