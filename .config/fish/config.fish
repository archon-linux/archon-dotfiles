# archon-dotfiles
# https://github.com/archon-linux/archon-dotfiles
# @nekwebdev
# LICENSE: GPLv3
# config: fish

### EXPORT ###
set fish_greeting		   # Suppresses fish's intro message
set TERM "xterm-256color"  # Sets the terminal type for proper colors
set fish_escape_delay_ms 500

### COLORS ###
if type -t set_colors > /dev/null 2>&1
    ### load colors from flavours
    set_colors
else
    # Base16 Gruvbox dark, medium defaults
    set fish_color_autosuggestion "#665c54"
    set fish_color_cancel -r
    set fish_color_command "#83a598"
    set fish_color_comment "#504945"
    set fish_color_cwd green
    set fish_color_cwd_root red
    set fish_color_end "#8ec07c"
    set fish_color_error "#fb4934"
    set fish_color_escape "#fe8019"
    set fish_color_history_current --bold
    set fish_color_host normal
    set fish_color_host_remote yellow
    set fish_color_match --background=brblue
    set fish_color_normal normal
    set fish_color_operator "#fe8019"
    set fish_color_param "#ebdbb2"
    set fish_color_quote "#b8bb26"
    set fish_color_redirection "#d3869b"
    set fish_color_search_match bryellow --background=brblack
    set fish_color_selection white --bold --background=brblack
    set fish_color_status red
    set fish_color_user brgreen
    set fish_color_valid_path --underline
    set fish_pager_color_completion normal
    set fish_pager_color_description "#8ec07c" yellow
    set fish_pager_color_prefix white --bold --underline
    set fish_pager_color_progress brwhite --background=cyan
end
### END OF COLORS ###

### start ssh agent
fish_ssh_agent

### initialize zoxide as an alias to cd
zoxide init --cmd cd fish | source

### FUNCTIONS ###
# recently installed packages
function rip --argument length -d "List the last n (100) packages installed"
    if test -z $length
        set length 100
    end
    expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort | tail -n $length | nl
end

# make terminal a nice file manager
# cd into a directory with fuzzy search
function fcd
    cd (find -type d | fzf)
end

# open a file with it's default application
function open
    xdg-open (find -type f | fzf)
end

# function to create a backup file
# ex: backup file.txt
# result: copies file as file.txt.bak
function backup --argument filename
    cp $filename $filename.bak
end

# functions to backup and restore gpg key
function backupgpg --argument key_name -d "Backup gpg key in gnupg folder"
    gpg --output $GNUPGHOME/$key_name.gpg --armor --export-secret-keys --export-options export-backup $key_name
    gpg --output $GNUPGHOME/$key_name.trust --export-ownertrust
    $GNUPGHOME/asc2gif.sh $GNUPGHOME/$key_name.gpg $GNUPGHOME/$key_name.gpg.gif
end

function publicgpg --argument key_name -d "Generate gpg public key in gnupg folder"
    gpg --output $GNUPGHOME/$key_name.gpg.pub --armor --export $key_name
    $GNUPGHOME/asc2gif.sh $GNUPGHOME/$key_name.gpg.pub $GNUPGHOME/$key_name.gpg.pub.gif
end

function restoregpg --argument key_name -d "Import gpg private key from filename in gnupg folder"
    gpg --import $GNUPGHOME/$key_name
end

# function to make qr out of ssh key
function qrssh --argument key -d "Create QR code from ssh key"
    $GNUPGHOME/asc2gif.sh $HOME/.ssh/$key $HOME/.ssh/$key.gif 
    $GNUPGHOME/asc2gif.sh $HOME/.ssh/$key.pub $HOME/.ssh/$key.pub.gif
end
### END OF FUNCTIONS ###


### ALIASES ###
# spark aliases
alias cl 'clear; seq 1 (tput cols) | sort -R | spark | lolcat'

# dotfiles
alias dotfiles "/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# navigation
alias .. 'cd ..' 
alias ... 'cd ../..'
alias .3 'cd ../../..'
alias .4 'cd ../../../..'
alias .5 'cd ../../../../..'

# changing "ls" to "exa"
alias ls 'exa -a --icons --color=always --group-directories-first' # my preferred listing
alias la 'exa -lag --icons --color=always --group-directories-first --octal-permissions --no-time --no-filesize'  # long format all files and dirs
alias ll 'exa -lagh --icons --color=always --group-directories-first --octal-permissions'  # long format all info
alias lg 'exa -la --icons --color=always --group-directories-first --octal-permissions --no-time --no-filesize --no-permissions --no-user --git' # git status info
alias sl 'sl | lolcat' # slow down train

# colorize grep output (good for log files)
alias grep 'grep --color=auto'
alias egrep 'egrep --color=auto'
alias fgrep 'fgrep --color=auto'

# confirm before overwriting something
alias cp 'cp -i'
alias mv 'mv -i'
alias rm 'rm -i'

# clipboard stuff
alias copypath "find -type f | fzf | sed 's/^..//' | tr -d '\n' | xclip -selection c"
alias cin 'xclip -selection c'
alias cout 'xclip -selection clipboard -o'

# nice curl
alias weather2 'curl wttr.in'

# list keys
alias listgpg 'gpg --list-secret-keys --keyid-format=long'

# remap applications
alias vim "nvim"
alias code "codium"

# get top process eating memory
alias psmem 'ps auxf | sort -nr -k 4'
alias psmem10 'ps auxf | sort -nr -k 4 | head -10'

# get top process eating cpu
alias pscpu 'ps auxf | sort -nr -k 3'
alias pscpu10 'ps auxf | sort -nr -k 3 | head -10'

# find running process
alias psgrep "ps aux | grep -v grep | grep -i -e VSZ -e"

# codium extensions
alias backupcode "codium --list-extensions | xargs -L 1 echo codium --install-extension > $GNUPGHOME/VSCodium/User/extensions-list.sh && chmod +x $GNUPGHOME/VSCodium/User/extensions-list.sh"
alias restorecode "fish $GNUPGHOME/VSCodium/User/extensions-list.sh"

# get the keycode from any keypress
alias keyscode "xev | awk -F'[ )]+' '/^KeyPress/ { a[NR+2] } NR in a { printf \"%-3s %s\n\", $5, $8 }'"

# get fastest mirrors in your neighborhood
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 30 --number 10 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 30 --number 10 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 30 --number 10 --sort age --save /etc/pacman.d/mirrorlist"

alias mirrorx "sudo reflector --age 6 --latest 20  --fastest 20 --threads 5 --sort rate --protocol https --save /etc/pacman.d/mirrorlist"
alias mirrorxx "sudo reflector --age 6 --latest 20  --fastest 20 --threads 20 --sort rate --protocol https --save /etc/pacman.d/mirrorlist"

# get fastest mirrors in United States
alias mirrorus "sudo reflector --country 'United States' -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrorusd "sudo reflector --country 'United States' --latest 30 --number 10 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirroruss "sudo reflector --country 'United States' --latest 30 --number 10 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrorusa "sudo reflector --country 'United States' --latest 30 --number 10 --sort age --save /etc/pacman.d/mirrorlist"

alias mirrorusx "sudo reflector --country 'United States' --age 6 --latest 20  --fastest 20 --threads 5 --sort rate --protocol https --save /etc/pacman.d/mirrorlist"
alias mirrorusxx "sudo reflector --country 'United States' --age 6 --latest 20  --fastest 20 --threads 20 --sort rate --protocol https --save /etc/pacman.d/mirrorlist"

# merge new settings in Xresources
alias merge "xrdb -merge ~/.Xresources"

# generate a new grub.cfg
alias update-grub "sudo grub-mkconfig -o /boot/grub/grub.cfg"

# get the error messages from journalctl
alias jctl "journalctl -p 3 -xb"
### END OF ALIASES ###

### ABBREVIATIONS ###
if status --is-interactive
    # git
    abbr --add --global gcm git commit -m
    abbr --add --global gcsm git commit -S -m
    abbr --add --global ga git add
    abbr --add --global gs git status
    # dotfiles
    abbr --add --global dcm dotfiles commit -m
    abbr --add --global dcsm dotfiles commit -S -m
    abbr --add --global da dotfiles add
    abbr --add --global ds dotfiles status
end
### END OF ABBREVIATIONS ###

### Prompt

# seq 1 (tput cols) | sort -R | spark | lolcat
colorscript --random

### Starship Prompt ###
starship init fish | source
