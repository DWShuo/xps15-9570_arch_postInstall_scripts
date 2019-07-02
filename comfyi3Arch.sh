#!/bin/bash

URL="https://raw.githubusercontent.com/DWShuo/.dotfiles/master/.config/i3/config"
mv ~/.config/i3/config ~/.config/i3/config.bak
wget $URL -P ~/.config/i3/
yay -Syu steam spotify python-pywal
rm .config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
pkill -KILL -u $USER
