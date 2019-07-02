#!/bin/bash
currentUSer=$USER

if grep -q AlwaysUnloadKernelDriver=true /etc/bumblebee/bumblebee.conf; then
    echo "Auto unload is already set to true"
else
    sudo -u root sed -i '/KernelDriver=nvidia.*/ {N; s/KernelDriver.*auto/KernelDriver=nvidia\nPMMethod=auto\nAlwaysUnloadKernelDriver=true/g}' /etc/bumblebee/bumblebee.conf
fi

sudo -u root echo $'Section "ServerFlags"\n\tOption "AutoAddGPU" "off"\nEndSection' > '/etc/X11/xorg.conf.d/01-noautogpu.conf'

sudo -u root echo $'Section "Device"\n\tIdentifier\t"Intel Graphics"\n\tDriver\t"intel"\n\tOption\t"TearFree" "true"\nEndSection' > '/etc/X11/xorg.conf.d/20-intel.conf'

sudo -u root echo $'w /sys/bus/pci/devices/0000:01:00.0/power/control - - - - auto' > '/etc/tmpfiles.d/nvidia_pm.conf'

sudo -u root systemctl enable bumblebeed.service

