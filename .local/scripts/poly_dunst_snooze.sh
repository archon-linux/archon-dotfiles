#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

case "$1" in
  --toggle)
    dunstctl set-paused toggle
    ;;
  *)
    ;;
esac

if [ "$(dunstctl is-paused)" = "true" ]; then
  echo ""
else
  echo ""
fi