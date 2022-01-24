#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3

###### => variables ############################################################
config_dir=${XDG_CONFIG_HOME-${HOME}/.config}

KEY=""
CITY=""
UNITS="metric"
SYMBOL="°"

API="https://api.openweathermap.org/data/2.5"

[[ -n "$WEATHER_APIKEY" ]] && KEY="$WEATHER_APIKEY"
[[ -n "$WEATHER_CITY" ]] && CITY="$WEATHER_CITY"

###### => functions ############################################################
function get_icon() {
    case $1 in
        # # Icons for weather-icons
        # 01d) icon="";;
        # 01n) icon="";;
        # 02d) icon="";;
        # 02n) icon="";;
        # 03*) icon="";;
        # 04*) icon="";;
        # 09d) icon="";;
        # 09n) icon="";;
        # 10d) icon="";;
        # 10n) icon="";;
        # 11d) icon="";;
        # 11n) icon="";;
        # 13d) icon="";;
        # 13n) icon="";;
        # 50d) icon="";;
        # 50n) icon="";;
        #   up) icon="" ;;
        # steady) icon="" ;;
        # down) icon="" ;;
        # *) icon="";

        # Icons for Nerf Fonts
        01d) icon="";;
        01n) icon="";;
        02d) icon="";;
        02n) icon="";;
        03*) icon="";;
        04*) icon="";;
        09d) icon="";;
        09n) icon="";;
        10d) icon="";;
        10n) icon="";;
        11d) icon="";;
        11n) icon="";;
        13d) icon="";;
        13n) icon="";;
        50d) icon="";;
        50n) icon="";;
         up) icon="" ;;
     steady) icon="" ;;
       down) icon="" ;;
          *) icon="";

        # Icons for Font Awesome 5 Pro
        # 01d) icon="";;
        # 01n) icon="";;
        # 02d) icon="";;
        # 02n) icon="";;
        # 03d) icon="";;
        # 03n) icon="";;
        # 04*) icon="";;
        # 09*) icon="";;
        # 10d) icon="";;
        # 10n) icon="";;
        # 11*) icon="";;
        # 13*) icon="";;
        # 50*) icon="";;
        # Next 3 needs fixing if you want to use Font Awesome
        #   up) icon="<" ;;
        # steady) icon="-" ;;
        # down) icon=">" ;;
        # *) icon="";
    esac

    echo $icon
}

function bar_clicked() {
    [[ -z "$KEY" ]] && ask_key || open_weather
    exit 0
}

function ask_key() {
    if [[ -n "$KEY" ]]; then
        user_key=$(echo "$KEY" | rofi -no-config -dmenu -i -theme "${config_dir}/rofi/themes/weatherapi.rasi" -p "API KEY" -mesg "Current API Key:" -l 1)
    else
        user_key=$(rofi -no-config -dmenu -i -theme "${config_dir}/rofi/themes/weatherapi.rasi" -p "API KEY" -l 0)
    fi
    [[ -n "${user_key}" ]] && sed -i "0,/KEY=.*/{s/KEY=.*/KEY=\"$user_key\"/}" "$0"

    if [[ -n "$CITY" ]]; then
        user_city=$(echo "$CITY" | rofi -no-config -dmenu -i -theme "${config_dir}/rofi/themes/weathercity.rasi" -p "City" -mesg "Current City:" -l 1)
    else
        user_city=$(rofi -no-config -dmenu -i -theme "${config_dir}/rofi/themes/weathercity.rasi" -p "City" -l 0)
    fi
    [[ -n "${user_city}" ]] && sed -i "0,/CITY=.*/{s/CITY=.*/CITY=\"$user_city\"/}" "$0"
    exit 0
}

function open_weather() {
    xdg-open "https://openweathermap.org/city/${CITY}"
    exit 0
}

function get_duration() {

    osname=$(uname -s)

    case $osname in
        *BSD) date -r "$1" -u +%H:%M;;
        *) date --date="@$1" -u +%H:%M;;
    esac

}

function output_data() {
    if [ -n "$CITY" ]; then
        if [ "$CITY" -eq "$CITY" ] 2>/dev/null; then
            CITY_PARAM="id=$CITY"
        else
            CITY_PARAM="q=$CITY"
        fi

        current=$(curl -sf "$API/weather?appid=$KEY&$CITY_PARAM&units=$UNITS")
        forecast=$(curl -sf "$API/forecast?appid=$KEY&$CITY_PARAM&units=$UNITS&cnt=1")
    else
        location=$(curl -sf https://location.services.mozilla.com/v1/geolocate?key=geoclue)

        if [ -n "$location" ]; then
            location_lat="$(echo "$location" | jq '.location.lat')"
            location_lon="$(echo "$location" | jq '.location.lng')"

            current=$(curl -sf "$API/weather?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS")
            forecast=$(curl -sf "$API/forecast?appid=$KEY&lat=$location_lat&lon=$location_lon&units=$UNITS&cnt=1")
        fi
    fi

    if [ -n "$current" ] && [ -n "$forecast" ]; then
        current_temp=$(echo "$current" | jq ".main.temp" | cut -d "." -f 1)
        current_icon=$(echo "$current" | jq -r ".weather[0].icon")

        forecast_temp=$(echo "$forecast" | jq ".list[].main.temp" | cut -d "." -f 1)
        forecast_icon=$(echo "$forecast" | jq -r ".list[].weather[0].icon")

        if [ "$current_temp" -gt "$forecast_temp" ]; then
            trend=$(get_icon "down")
        elif [ "$forecast_temp" -gt "$current_temp" ]; then
            trend=$(get_icon "up")
        else
            trend=$(get_icon "steady")
        fi

        echo "$(get_icon "$current_icon")  $current_temp$SYMBOL $trend $(get_icon "$forecast_icon")  $forecast_temp$SYMBOL"
    else
        echo "error"
    fi
    exit 0
}

###### => main ############################################################
[[ "$1" = "click" ]] && bar_clicked
[[ "$1" = "rclick" ]] && ask_key
[[ -z "$KEY" ]] && echo "Right click to set API KEY" && exit 0
output_data
