#!/usr/bin/env bash

if [ -f /etc/NIXOS ] && ! command -v dialog &> /dev/null; then
    exec nix-shell -p dialog --run "$(printf "%q " "$0" "$@")"
fi

check_dependencies() {
    if ! command -v dialog &> /dev/null; then
        if [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm dialog
            sudo pacman -S wlogout
            sudo pacman -S swww
            sudo pacman -S waybar
            sudo pacman -S hyprland
        else
            exit 1
        fi
    fi
}

check_dependencies

BACKTITLE="Krisi's Dotfiles Installer"
HEIGHT=15
WIDTH=65

dialog --backtitle "$BACKTITLE" \
--title " Welcome! Hi I'm Kristiyan " \
--yesno "Hi! I'm Kristiyan. This is the project I've been working on.\n\n                  Do you want to continue?" \
$HEIGHT $WIDTH

if [ $? -ne 0 ]; then
    clear
    exit 0
fi

TEMP_FILE=$(mktemp)
dialog --backtitle "$BACKTITLE" \
--title " Selection " \
--checklist "Select which configs to install:" $HEIGHT $WIDTH 10 \
"Hyprland" "Window Manager config" ON \
"Waybar" "Status bar theme" ON \
"Kitty" "Terminal configuration" ON \
"SwayNC" "Notification center" ON \
"Zsh" "Shell configuration (.zshrc)" OFF \
"Themes" "Vimix & Catppuccin themes" OFF 2> $TEMP_FILE

if [ $? -ne 0 ]; then
    rm $TEMP_FILE
    clear
    exit 0
fi

clear
exit 0
SELECTED=$(cat $TEMP_FILE)
rm $TEMP_FILE

clear
echo "Installing selected components: $SELECTED"

# Тук добави реалните си команди, например:
# git clone https://github.com/Wkrisi/my-configuration-files.git

dialog --backtitle "$BACKTITLE" \
--title " Finished " \
--msgbox "Installation completed successfully!\n\nPlease restart your session." 8 50

clear
