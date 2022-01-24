# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3

# load user envirnoment variables
ENVIRONMENTD="$HOME/.config/environment.d"
set -a
if [ -d "$ENVIRONMENTD" ]; then
    for conf in "$ENVIRONMENTD"/*.conf
    do
        # shellcheck source=/dev/null
        . "$conf"
    done
fi
set +a