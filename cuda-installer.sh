#!/bin/bash

echo "Install CUDA? (press enter for install or write "skip"):"
read cuda_install
cuda_install=$(echo $cuda_install | tr -cd '[:alnum:]_-')
cuda_install=${cuda_install:-1}
echo "You entered: $cuda_install"

if [[ "${cuda_install:0:4}" == "skip" ]]; then
    echo "CUDA installing skipped"
else
    sudo pacman -Sy --noconfirm cudnn
fi

# Clean cache
sudo pacman -Scc --noconfirm
