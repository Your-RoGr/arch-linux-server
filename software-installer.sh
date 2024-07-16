#!/bin/bash

# docker
sudo pacman -Sy --noconfirm docker docker-compose
sudo systemctl enable docker
sudo systemctl start docker

chmod +x docker/compose.sh
chmod +x docker/tabby.sh
chmod +x docker/tabby-cuda.sh

# python3.10 + jupyter-lab
yay -S --noconfirm python310
python3.10 -m venv ~/jupyterlab
source ~/jupyterlab/bin/activate
pip install -r requirements.txt
cp ~/jupyterlab/bin/jupyter-lab /app/jupyter-lab
deactivate

# Clean cache
sudo pacman -Scc --noconfirm
yay -Scc --noconfirm

sudo reboot