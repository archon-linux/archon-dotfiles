# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3

#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# To add support for TTYs this line can be optionally added.
# shellcheck source=/dev/null
source ~/.cache/wal/colors-tty.sh

exec fish