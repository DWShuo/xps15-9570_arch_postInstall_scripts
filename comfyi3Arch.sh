#!/bin/bash
currentUser=$USER
echo 'Configuring i3-gaps'
URL="https://raw.githubusercontent.com/DWShuo/.dotfiles/master/.config/i3/config"
mv /home/$currentUser/.config/i3/config /home/$currentUser/.config/i3/config.bak
wget $URL -P /home/$currentUser/.config/i3/
echo 'Installling steam spotify pywal bluetooth tlp...'
yay -Syu steam spotify python-pywal blueman bluez tlp
echo 'Setting up pywal'
echo $'(cat ~/.cache/wal/sequences &)' >> '.zshrc'
echo $'wal -R' > '.xinitrc'
sudo -u root systemctl enable bluetooth.service
echo 'Setting up tlp'
sudo -u root tlp start
sudo -u root systemctl enable tlp.service
sudo -u root systemctl enable tlp-sleep.service
sudo -u root systemctl mask systemd-rfkill.service
sudo -u root systemctl mask systemd-rfkill.socket

echo 'Logging out to apply settings'
sleep 3s
pkill -KILL -u $USER
