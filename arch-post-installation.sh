#!/bin/bash

sudo rm -rf /local

sudo cp pacman/pacman.conf /etc/pacman.conf

sudo pacman -Syyu --noconfirm
sudo pacman -Sy --noconfirm intel-media-driver
sudo pacman -Sy --noconfirm libva-intel-driver
sudo pacman -Sy --noconfirm libva-intel-driver libva-mesa-driver mesa-vdpau

echo "Enter your GPU manufacturer [1 - nvidia (For GTX 750 and newer), 2 - amd or skip] (press enter for default: skip):"
read vendor
vendor=$(echo $vendor | tr -cd '[:alnum:]_-')
vendor=${vendor:-skip}
echo "You entered: $vendor"

if [[ "${vendor:0:4}" == "skip" ]]; then
    echo "Driver installing skipped"
elif [[ $vendor =~ ^[0-9]+$ ]]; then
    if [ "$vendor" -eq 1 ]; then
        echo "Installing Nvidia drivers..."

        sudo mkdir /etc/pacman.d/hooks

        cat << EOL | sudo tee /etc/pacman.d/hooks/nvidia.hook > /dev/null
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
# Измените "linux" в строке выше, если вы используете другое ядро

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOL

        # proprietary driver
        sudo pacman -Sy --noconfirm nvidia nvidia-utils nvidia-settings lib32-nvidia-utils nvtop
        # Enable the nvidia service
        sudo systemctl enable nvidia-persistenced.service

        cat << EOL | sudo tee /etc/modprobe.d/nvidia_drm.conf > /dev/null
options nvidia_drm modeset=1
EOL

    elif [ "$vendor" -eq 2 ]; then
        echo "Installing AMD drivers..."
        sudo pacman -Sy --noconfirm xf86-video-amdgpu mesa mesa-demos vulkan-icd-loader lib32-mesa lib32-vulkan-icd-loader
        # Enable the amdgpu service (if necessary)
        sudo systemctl enable amdgpu-init.service
    else
        echo "Invalid entry. Please enter either 1 or 2."
    fi
else
    echo "Invalid entry. Please enter either 1 or 2."
fi

# Install ntp
echo "Installing ntp"
sudo pacman -Sy --noconfirm ntp
sudo systemctl enable ntpd

# Install YAY
echo "Installing git, base-devel, wget and YAY"
sudo pacman -Sy --noconfirm git base-devel wget
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

cd ..
rm -rf ~/yay

# Install other soft
echo "Installing clang, gdb, ninja, gcc, cmake, fastfetch, htop, bashtop, lf, fish"
sudo pacman -Sy --noconfirm clang gdb ninja gcc cmake fastfetch htop bashtop lf fish

sudo chsh -s /bin/fish $(whoami)

sudo systemctl enable systemd-homed
sudo systemctl start systemd-homed

# echo "Installing iwgtk"
# yay -Sy --noconfirm iwgtk
# sudo systemctl enable iwd.service
# sudo systemctl start iwd.service

chmod +x software-installer.sh
./software-installer.sh
