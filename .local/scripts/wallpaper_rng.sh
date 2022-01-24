#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

###### => dependencies check ###################################################
for name in flavours feh betterlockscreen; do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\nInstall $name.";deps=1; }
done
if [[ $deps -eq 1 ]]; then
  { echo -en "\nInstall the above before running this script\n";exit 1; }
fi

###### => display help screen ##################################################
function display_help() {
    echo "  Description:"
    echo "    Grabs a random image from a path set as WALLPAPER env variable \
              and sets it as a wallpaper."
    echo "    Optionally generate a base16 scheme with 'flavours' based on \
              the wallpaper or applies a preset scheme."
    echo
    echo "  Usage:"
    echo "    wallpaper_rng.sh"
    echo "    wallpaper_rng.sh [--flavours]"
    echo "    wallpaper_rng.sh [--flavours] <scheme>"
    echo
    echo "  Options:"
    echo "    -h --help               Show this screen."
    echo "    -f --flavours           Generate a base16 scheme based on the wallpaper colors."
    echo "    -f --flavours <scheme>  Apply a base16 preset scheme."
    echo
    exit 0
}
###### => parse arguments ######################################################
last_input=""
while (( "$#" )); do
  case "$1" in
    -h|--help)
      display_help; shift
      ;;
    -f|--flavours) # example for arg with input
      use_flavours="true"; shift
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        color_scheme=$2; shift
      fi
      ;;
    --*|-*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2; exit 1
      ;;
    *) # preserve positional arguments and get last input
      last_input="$last_input $1"; shift
      ;;
  esac
done

###### => variables ############################################################
no_env_wall="Set the WALLPAPERS environment variable to your wallpapers folder path"
more_wall="You need at leat 3 wallpapers, else this is pretty pointless..."

###### => main #################################################################
# check for wallpaper folder env variable
[[ -z $WALLPAPERS ]] && notify-send "Random wallpaper" "$no_env_wall" \
                                  -i dialog-warning -u critical \
                                  && exit 1

# make sure we have enough wallpapers
wallpapers_list=$(find "$WALLPAPERS" -type f -regex "^.*\.\(png\|jpg\|jpeg\)$")
count=$(echo "$wallpapers_list" | wc -l)
[[ 2 -gt $count ]] && notify-send "Random wallpaper" "$more_wall" \
                                  -i dialog-warning -u critical \
                                  && exit 1

# pick a random wallpaper
current=$(sed -e "s/.*'\(.*\)'.*/\1/" "$HOME"/.fehbg | sed '2q;d')
new=$(echo "$wallpapers_list" | shuf -n 1)

# make sure it's not the same one we already have set
while [ "$new" = "$current" ]; do
  new=$(echo "$wallpapers_list" | shuf -n 1)
done

# set the wallpaper with feh
feh --bg-fill "$new"

# copy the wallpaper for idiotic lightdm that wont use user directories...
cp -f "$new" "/usr/share/backgrounds/lightdm/wallpaper.jpg"

# generate a scheme with flavours?
if [[ -n "$use_flavours" ]]; then
  if [[ -n "$color_scheme" ]]; then
    flavours apply "$color_scheme"
  else
    flavours generate dark "$new" && flavours apply generated
  fi
fi

# generate betterlockscreen caches
betterlockscreen --display 1 -u "$new" --fx dimblur

exit 0
