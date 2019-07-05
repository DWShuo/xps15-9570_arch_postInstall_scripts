#!/bin/bash
currentUser=$USER
echo 'Installling steam spotify pywal bluetooth tlp ncdu...'
yay -Syu steam python-pywal blueberry tlp ncdu 
echo 'Setting up pywal'
echo $'(cat ~/.cache/wal/sequences &)' >> '.zshrc'
echo $'wal -R' > '.xinitrc'
#sudo -u root systemctl enable bluetooth.service
echo 'Setting up tlp'
sudo -u root tlp start
sudo -u root systemctl enable tlp.service
sudo -u root systemctl enable tlp-sleep.service
sudo -u root systemctl mask systemd-rfkill.service
sudo -u root systemctl mask systemd-rfkill.socket
echo 'Setting up mpd group'
sudo -u root gpasswd -a mpd users
sudo -u root chmod 710 ~/
sudo -u root gpasswd -a mpd audio
echo 'Restoring dotfiles'
git clone https://github.com/DWShuo/dotfiles.git
chmod u+x restore.sh
/bin/bash /home/$currentUser/dotfiles/restore.sh

#echo 'Logging out to apply settings'
#sleep 3s
#pkill -KILL -u $USER
