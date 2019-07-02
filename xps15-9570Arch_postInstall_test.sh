#!/bin/bash

currentUser=$SUDO_USER
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

echo $currentUser
sudo -u $currentUser git clone https://aur.archlinux.org/yay.git
function yayDir(){
    cd ./yay
}
yayDir
sudo -u $currentUser makepkg -si
echo "$(tput setaf 2)Downloading bumblebee-git, bbswitch-git nvidia, powertop, mesa-demos...$(tput sgr 0)"
sudo -u $currentUser yay -Syu bumblebee nvidia powertop mesa-demos bbswitch-git

echo "$(tput setaf 2)Adding user to bumblebee group$(tput sgr 0)"
usermod -a -G bumblebee $currentUser

echo "$(tput setaf 2)Configure bumblebee$(tput sgr 0)"

if grep -q AlwaysUnloadKernelDriver=true /etc/bumblebee/bumblebee.conf; then
    echo "bumblebee alread configured"
else
    sudo -u root cp /etc/bumblebee/bumblebee.conf /etc/bumblebee/bumblebee.conf.bak

    #:a create a label 'a'
    #N append the next line to the pattern space
    #$! if not the last line, ba branch (go to) label 'a'
    #s substitute, /START.*END/ by SINGLEWORD,/g global match (as many times as it can)

    sudo -u root sed -i ':a;N;$!ba;s/\[driver-nvidia.*xorg\.conf\.nouveau/KernelDriver=nvidia\nPMMethod=auto\nAlwaysUnloadKernelDriver=true/g' /etc/bumblebee/bumblebee.conf
fi

sudo -u root echo $'Section "ServerFlags"\n\tOption "AutoAddGPU" "off"\nEndSection' > '/etc/X11/xorg.conf.d/01-noautogpu.conf'

sudo -u root echo $'Section "Device"\n\tIdentifier\t"Intel Graphics"\n\tDriver\t"intel"\n\tOption\t"TearFree" "true"\nEndSection' > '/etc/X11/xorg.conf.d/20-intel.conf'

sudo -u root echo $'w /sys/bus/pci/devices/0000:01:00.0/power/control - - - - auto' > '/etc/tmpfiles.d/nvidia_pm.conf'

echo "$(tput setaf 2)Black listing nouveau$(tput sgr 0)"
if grep -q ipmi_devintf /etc/modprobe.d/blacklist.conf; then
    echo "Items already  black listed"
else
    sudo -u root echo $'blacklist nouveau\nblacklist rivafb\nblacklist: nvidiafb\nblacklist rivatv\nblacklist nv' >> '/etc/modprobe.d/blacklist.conf'
fi

sudo -u root systemctl enable bumblebeed.service

