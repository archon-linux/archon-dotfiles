#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# Modified: @nekwebdev
# LICENSE: GPLv3
# Original:
# https://github.com/lu0/rofi-blurry-powermenu
# Powermenu for Rofi
# Author : Lucero Alvarado
# Github : @lu0
set -e

###### => dependencies check ###################################################
# convert is part of imagemagick
for name in rofi scrot convert; do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\nInstall $name.";deps=1; }
done
if [[ $deps -eq 1 ]]; then
  { echo -en "\nInstall the above before running this script\n";exit 1; }
fi

###### => display help screen ##################################################
function display_help() {
  echo "  Description:"
  echo "    Opens a rofi menu with regular shutdown options"
  echo
  echo "  Usage:"
  echo "    rofi_powermenu.sh"
  echo
  echo "  Options:"
  echo "    --help                 Show this screen."
  echo
  exit 0
}
[[ "$1" == "--help" ]] && display_help

###### => variables ############################################################
# rofi arguments
rofi_theme="${XDG_CONFIG_HOME-${HOME}/.config}/rofi/themes/powermenu.rasi"
rofi_cmd="rofi -no-config -dmenu -theme ${rofi_theme}"
# options as nerd fonts characters   
shutdown="";
reboot="";
sleep="⏾";
logout="";
lock="";
options="$shutdown\n$reboot\n$sleep\n$logout\n$lock"

###### => main #################################################################

# fake blurred background
# blur_bg="/tmp/blur_bg"
# rm -f "${blur_bg}.jpg" && scrot -z "${blur_bg}.jpg"
# convert "${blur_bg}.jpg" -blur 0x10 -auto-level "${blur_bg}.jpg"
# convert "${blur_bg}.jpg" "${blur_bg}.png"

# font size according to screen dimensions
display_width=1920
actual_width=$(xdpyinfo | grep dimensions | awk '{print $2}' | cut -d 'x' -f 1 )
default_fontsize=100
final_fontsize=$(echo "$actual_width/$display_width*$default_fontsize" | bc -l)

selected="$(echo -e "$options" | $rofi_cmd \
  -font "Nerd Font, $final_fontsize")"

case $selected in
  "$shutdown")
    systemctl poweroff
    ;;
  "$reboot")
    systemctl reboot
    ;;
  "$sleep")
    systemctl suspend
    ;;
  "$logout")
    system_logout.sh || ( xfce4-session-logout --logout || mate-session-save --logout )
    ;;
  "$lock")
    system_lock.sh || ( xflock4 || mate-screensaver-command -l )
    ;;
esac

exit 0
