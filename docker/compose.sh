#!/bin/bash

cd "$(dirname $0)"
sudo mkdir -p ./nginx
sudo touch ./nginx/error.log
sudo touch ./nginx/access.log
sudo docker compose up -d --build
