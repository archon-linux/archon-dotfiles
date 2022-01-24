#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

playbook_dir="$( dirname "$0" )"

[[ -f "$playbook_dir"/vault.yml ]] && ansible-playbook \
                    --extra-vars @"$playbook_dir"/vault.yml \
                    --ask-vault-pass \
                    --ssh-common-args='-o StrictHostKeyChecking=no' \
                    -i "$playbook_dir"/inventory "$playbook_dir"/playbook.yml