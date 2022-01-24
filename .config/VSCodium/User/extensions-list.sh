#!/usr/bin/env bash
# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
set -e

codium --install-extension dlasagno.wal-theme
codium --install-extension sainnhe.gruvbox-material
codium --install-extension arcticicestudio.nord-visual-studio-code
codium --install-extension PKief.material-icon-theme
codium --install-extension eamodio.gitlens
codium --install-extension bmalehorn.vscode-fish
codium --install-extension naumovs.color-highlight
codium --install-extension bmalehorn.vscode-fish
codium --install-extension timonwong.shellcheck
codium --install-extension formulahendry.code-runner
codium --install-extension aaron-bond.better-comments

touch "$HOME"/.config/VSCodium/User/.extensions_installed