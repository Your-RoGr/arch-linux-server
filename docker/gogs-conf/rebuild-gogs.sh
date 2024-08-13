#!/bin/bash

sudo docker compose stop extrolabs_gogs
sudo docker compose rm extrolabs_gogs
sudo docker compose up -d --build extrolabs_gogs
sudo docker compose logs extrolabs_gogs -f
