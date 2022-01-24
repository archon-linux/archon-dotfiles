#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

###### => dependencies check ###################################################
for name in sxiv feh rofi betterlockscreen; do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\nInstall $name.";deps=1; }
done
if [[ $deps -eq 1 ]]; then
  { echo -en "\nInstall the above before running this script\n";exit 1; }
fi

###### => display help screen ##################################################
function display_help() {
    echo "  Description:"
    echo "    Select a new wallpaper to apply."
    echo "    Generate a base16 scheme with 'flavours' \
              based on the wallpaper or applies a preset scheme."
    echo
    echo "  Usage:"
    echo "    rofi_wallpaper.sh"
    echo "    rofi_wallpaper.sh [--silent] [--only-colors]"
    echo
    echo "  Options:"
    echo "    -h --help         Show this screen."
    echo "    -s --silent       No dunst notifications."
    echo "    -c --only-colors  Only change the color scheme."
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
    -s|--silent)
      silent="true"; shift
      ;;
    -c|--only-colors)
      skip_wp="true"; shift
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
config_dir=${XDG_CONFIG_HOME-${HOME}/.config}
rofi_cmd="rofi -dmenu -theme ${config_dir}/rofi/themes/launcher.rasi \
                -no-config -sort -no-lazy-grab -matching fuzzy -i"
# help texts
help_wallpapers="Think about setting a default wallpapers path as the 'WALLPAPERS' environment variable."
help_sxiv="h,j,k,l to move, m or right click to choose as many as needed (multi screen), q to close and confirm."

# figure out monitors
# select the first monitor
monitor1=$(xrandr --listactivemonitors | grep "+" | awk '{print $4}' | awk NR==1)
[[ -n $monitor1 ]] && monitors[0]="$monitor1"
# select the second monitor
monitor2=$(xrandr --listactivemonitors | grep "+" | awk '{print $4}' | awk NR==2)
[[ -n $monitor2 ]] && monitors[1]="$monitor2"
# select the third monitor
monitor3=$(xrandr --listactivemonitors | grep "+" | awk '{print $4}' | awk NR==3)
[[ -n $monitor3 ]] && monitors[2]="$monitor3"
# get screen resolution to calculate the center
mapfile -t x < <(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)
mapfile -t y < <(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)
xl=$(echo "(${x[0]}-500)/2" | bc)
yl=$(echo "(${y[0]}-500)/2" | bc)
center_location="500x500+${xl}+${yl}"

###### => functions ############################################################
function set_colors() {
  ###### => get the scheme
  # show a rofi menu to ask for color scheme
  schemes_dir="${XDG_DATA_HOME}/flavours/base16/schemes"

  base16_schemes=$( find "$schemes_dir" -type f -printf "%f\n" \
                    | sed 's/\.yaml//g' | sed 's/\.yml//g' | sort -u )

  last_scheme=$( cat "$XDG_DATA_HOME"/flavours/lastscheme || echo "")

  flavours_scheme=$( echo -e "$base16_schemes" \
                  | $rofi_cmd -select "$last_scheme" -p "Choose base16 color scheme" )

  [[ -z $flavours_scheme ]] && exit 0

  ###### => set the scheme
  # if generated, run flavours generate on the first wallpaper
  if [[ "$flavours_scheme" = "generated" ]]; then
    # show a rofi menu to ask for light or dark theme
    style=$( echo -e "dark\nlight" | $rofi_cmd -select "dark" -p "Choose style" )
    [[ -z $style ]] && exit 0
    gen_wallpaper="$1"
    [[ -z $gen_wallpaper ]] && \
        gen_wallpaper=$(sed -e "s/.*'\(.*\)'.*/\1/" "$HOME"/.fehbg | sed '2q;d')
    flavours generate "$style" "$gen_wallpaper"
  fi

  # apply base16 theme with flavours
  flavours apply "$flavours_scheme"

  # generate a color palette and send a notification
  theme_path=$( find "$XDG_DATA_HOME"/flavours/base16/schemes -type f -name "${flavours_scheme}.*" )
  python "$HOME"/.local/scripts/base16_gen_spectrum.py "$theme_path" /tmp/base16.png
  [[ -z $silent ]] && notify-send "Flavours" "Color scheme set to $flavours_scheme" -i /tmp/base16.png -u low
  rm -f /tmp/base16.png
}

###### => main #################################################################
# only set the color scheme?
[[ -n $skip_wp ]] && set_colors && exit 0

# figure out the wallpapers folder
if [[ -z $WALLPAPERS ]]; then
  [[ -z $silent ]] && notify-send "Wallpapers" "$help_wallpapers" -i dialog-warning -u critical
  # find all directories containing .jpg and .png images in home and usr
  images_paths=$( find /home /usr -path '*.cache/sxiv' -prune -o -type f \( -name '*.jpg' -o -name '*.png' \) -printf '%h\n' | sort -u )
  # show a rofi menu to ask for a wallpapers path
  path_wallpapers=$( echo -e "$images_paths" | $rofi_cmd -p "Wallpapers path")
  [[ -z $path_wallpapers ]] && exit 0
else
  path_wallpapers=${WALLPAPERS}
fi

###### => show a sxiv windows to pick the wallpapers
[[ -z $silent ]] && notify-send "Wallpapers" "$help_sxiv" -i dialog-information -u critical
wallpapers_list=$(sxiv -t -o -r -b -g "$center_location" "$path_wallpapers" -N "Wallpaper Picker" | xargs)
killall dunst
[[ -z $wallpapers_list ]] && exit 0

# make it into an array
old_IFS=$IFS
IFS=" " read -r -a wallpapers <<< "$wallpapers_list"
IFS=${old_IFS}

# strip the wallpapers array down to our monitor count
wallpapers=( "${wallpapers[@]::${#monitors[@]}}" )

###### => ask for and set a color scheme
set_colors "${wallpapers[0]}"

# check our wallpaper fill options
[[ -z $WALLPAPERS_FILL ]] && fill_type="--bg-fill" || fill_type=${WALLPAPERS_FILL}

# apply the new wallpaper(s)
feh "$fill_type" "${wallpapers[@]}"
[[ -z $silent ]] && notify-send "Wallpapers" "Wallpaper set on all monitors" -i "${wallpapers[0]}" -u low

# copy the wallpaper for idiotic lightdm that wont use user directories...
cp -f "${wallpapers[0]}" "/usr/share/backgrounds/lightdm/wallpaper.jpg"

# generate betterlockscreen caches
lock_args="--display 1 --fx dimblur"
for wallpaper in "${wallpapers[@]}"; do
   lock_args="$lock_args -u $wallpaper"
done
[[ -z $silent ]] && notify-send "Wallpapers" "Rendering lockscreen effects..." -i "${wallpapers[0]}" -u critical
betterlockscreen ${lock_args}
killall dunst
[[ -z $silent ]] && notify-send "Wallpapers" "Done rendering lockscreen effects" -i "${wallpapers[0]}" -u low

exit 0
