#!/bin/bash

currentUser=$USER
#Change suspend mode from s2idle to deep
echo "$(tput setaf 2)Changing suspend mode to deep...$(tput sgr 0)"
grub_param='"mem_sleep_default=deep"'
sudo -u root sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=${grub_param}/" /etc/default/grub
#update grub
echo 'Updating grub'
sudo -u root grub-mkconfig -o /boot/grub/grub.cfg

#Set up Nvidia optimus GPU switching
echo "$(tput setaf 2)Setting up GPU switching...$(tput sgr 0)"

echo "$(tput setaf 2)Downloading yay AUR package manager...$(tput sgr 0)"
sudo -u $currentUser git clone https://aur.archlinux.org/yay.git
function yayDir(){
    cd ./yay
}
yayDir
sudo -u $currentUser makepkg -si

echo "$(tput setaf 2)Downloading bumblebee-git, nvidia, mesa-demos...$(tput sgr 0)"
sudo -u $currentUser yay -Syu bumblebee-git bbswitch nvidia mesa-demos primus


