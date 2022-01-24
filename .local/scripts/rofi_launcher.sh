#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

###### => variables ############################################################
themefile="${XDG_CONFIG_HOME-${HOME}/.config}/rofi/themes/launcher.rasi"
rofi_cmd="rofi -no-config -no-lazy-grab -matching fuzzy -modi run,drun -theme ${themefile}"

###### => main #################################################################
if [ "$1" = "run" ]; then
    $rofi_cmd -show run
else
    $rofi_cmd -show drun
fi

exit 0
