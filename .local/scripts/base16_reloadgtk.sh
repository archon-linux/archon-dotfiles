#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

gsettings set org.gnome.desktop.interface gtk-theme '' && sleep 0.1
gsettings set org.gnome.desktop.interface gtk-theme 'FlatColor'
echo "Net/ThemeName \"FlatColor\"" > /tmp/reloadxsettingsd
timeout 0.2s xsettingsd -c /tmp/reloadxsettingsd &
sleep 0.1s
rm -f /tmp/reloadxsettingsd
