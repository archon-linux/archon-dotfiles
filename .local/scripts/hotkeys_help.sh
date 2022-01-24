#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# awk ninjutsu from https://www.reddit.com/r/bspwm/comments/aejyze/tip_show_sxhkd_keybindings_with_fuzzy_search/
# @nekwebdev
# LICENSE: GPLv3
set -e

###### => variables ############################################################
config_dir="${XDG_CONFIG_HOME-${HOME}/.config}"
rofi_theme="$config_dir"/rofi/themes/hotkeys_help.rasi

###### => main #################################################################
# load sxhkd hotkeys
help_files="$config_dir"/sxhkd/sxhkdrc
help_text=$( awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' "$help_files" | column -t -s $'\t' )

# load openbox hotkeys help
if [[ $( ps -e | openbox ) ]]; then
    help_files="$config_dir"/openbox/hotkeys.help
    help_text2=$( awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' "$help_files" | column -t -s $'\t' )
    help_text="$help_text\n$help_text2"
fi

# load rofi-pass hotkeys
help_files="$config_dir"/rofi-pass/hotkeys.help
help_text2=$( awk '/^[a-z]/ && last {print $0,"\t",last} {last=""} /^#/{last=$0}' "$help_files" | column -t -s $'\t' )
help_text="$help_text\n$help_text2"

echo -e "$help_text" |
    rofi -dmenu -i -no-config -no-show-icons -theme "$rofi_theme" -p "Hotkeys"

exit 0
