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

echo "$(tput setaf 2)Downloading bumblebee, nvidia, powertop, mesa-demos...$(tput sgr 0)"
sudo -u $currentUser yay -Syu bumblebee nvidia powertop mesa-demos

echo "$(tput setaf 2)Adding user to bumblebee group$(tput sgr 0)"
usermod -a -G bumblebee $currentUser

echo "$(tput setaf 2)Configure bumblebee$(tput sgr 0)"
if grep -q PMMethod=none /etc/bumblebee/bumblebee.conf; then
    echo "bumblebee alread configured"
else
    sudo -u root cp /etc/bumblebee/bumblebee.conf /etc/bumblebee/bumblebee.conf.bak

    #:a create a label 'a'
    #N append the next line to the pattern space
    #$! if not the last line, ba branch (go to) label 'a'
    #s substitute, /START.*END/ by SINGLEWORD,/g global match (as many times as it can)

    sudo -u root sed -i ':a;N;$!ba;s/\[driver-nvidia.*xorg\.conf\.nouveau/Driver=nvidia\nPMMethod=none/g' /etc/bumblebee/bumblebee.conf
fi

echo "$(tput setaf 2)Configure X11 noautogpu$(tput sgr 0)"
sudo -u root echo $'Section "ServerFlags"\n\tOption "AutoAddGPU" "off"\nEndSection' > '/etc/X11/xorg.conf.d/01-noautogpu.conf'

echo "$(tput setaf 2)Creating disable-ipmi.conf$(tput sgr 0)"
sudo -u root echo $'install ipmi_msghandler /usr/bin/false\ninstall ipmi_devintf /usr/bin/false' > '/etc/modprobe.d/disable-ipmi.conf'

echo "$(tput setaf 2)Creating disable-nvidia.conf$(tput sgr 0)"
sudo -u root echo $'install nvidia /bin/false' > '/etc/modprobe.d/disable-nvidia.conf'

echo "$(tput setaf 2)Black listing nouveau and ipmi$(tput sgr 0)"
if grep -q ipmi_devintf /etc/modprobe.d/blacklist.conf; then
    echo "Items already  black listed"
else
    sudo -u root echo $'blacklist nouveau\nblacklist rivafb\nblacklist: nvidiafb\nblacklist rivatv\nblacklist nv\nblacklist nvidia\nblacklist nvidia-drm\nblacklist nvidia-modeset\nblacklist nvidia-uvm\nblacklist ipmi_msghandler\nblacklist ipmi_devintf' >> '/etc/modprobe.d/blacklist.conf'
fi

echo "$(tput setaf 2)Creating enableGPU and disableGPU script$(tput sgr 0)"
sudo -u $currentUser echo $'#!/bin/sh\nmodprobe -r nvidia_drm\nmodprobe -r nvidia_uvm\nmodprobe -r nvidia_modeset\nmodprobe -r nvidia\n# Change NVIDIA card power control\necho -n auto > /sys/bus/pci/devices/0000\:01\:00.0/power/control\nsleep 1\n# change PCIe power control\necho -n auto > /sys/bus/pci/devices/0000\:00\:01.0/power/control\nsleep 1\n# Lock system form loading nvidia module\nmv /etc/modprobe.d/disable-nvidia.conf.disable /etc/modprobe.d/disable-nvidia.conf' > /home/$currentUser/disableGPU.sh

sudo -u $currentUser echo $'#!/bin/sh\n# allow to load nvidia module\nmv /etc/modprobe.d/disable-nvidia.conf /etc/modprobe.d/disable-nvidia.conf.disable\n# Remove NVIDIA card (currently in power/control = auto)\necho -n 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove\nsleep 1\n# change PCIe power control\necho -n on > /sys/bus/pci/devices/0000\:00\:01.0/power/control\nsleep 1\n# rescan for NVIDIA card (defaults to power/control = on)\necho -n 1 > /sys/bus/pci/rescan\n# someone said that modprobe nvidia is needed also to load nvidia, to check\n# modprobe nvidia' > /home/$currentUser/enableGPU.sh

echo "$(tput setaf 2)Createing service to disable nvidia on shutdown$(tput sgr 0)"
sudo -u $currentUser echo $'[Unit]\nDescription=Disables Nvidia GPU on OS shutdown\n[Service]\nType=oneshot\nRemainAfterExit=true\nExecStart=/bin/true\nExecStop=/bin/bash -c "mv /etc/modprobe.d/disable-nvidia.conf.disable /etc/modprobe.d/disable-nvidia.conf || true"\n[Install]\nWantedBy=multi-user.target' > '/etc/systemd/system/disable-nvidia-on-shutdown.service'

echo "$(tput setaf 2)Reload systemd daemons$(tput sgr 0)"
sudo -u root systemctl daemon-reload
sudo -u root systemctl enable disable-nvidia-on-shutdown.service
sudo -u root echo $'w /sys/bus/pci/devices/0000:01:00.0/power/control - - - - auto' > '/etc/tmpfiles.d/nvidia_pm.conf'


echo "$(tput setaf 1)Reboot for settings to take effect...$(tput sgr 0)"
