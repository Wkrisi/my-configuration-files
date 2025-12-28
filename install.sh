#!/usr/bin/env bash

if [ -f /etc/NIXOS ] && ! command -v dialog &> /dev/null; then
    exec nix-shell -p dialog --run "$(printf "%q " "$0" "$@")"
fi

install_packages() {
    # Проверка за мениджър на пакети
    if [ -f /etc/arch-release ]; then
        INSTALL_CMD="sudo pacman -S --noconfirm"
    elif [ -f /etc/NIXOS ]; then
        INSTALL_CMD="nix-env -iA nixos"
    else
        echo "Unsupported system."
        exit 1
    fi

    echo "Installing base dependencies..."
    $INSTALL_CMD dialog wlogout swww waybar hyprland swaync kitty thunar hyprlock hypridle

    if [[ $SELECTED == *"Hyprland"* ]]; then
        $INSTALL_CMD hyprland
    fi
    
    if [[ $SELECTED == *"Waybar"* ]]; then
        $INSTALL_CMD waybar
    fi

    if [[ $SELECTED == *"Zsh"* ]]; then
        $INSTALL_CMD zsh
    fi

    # Специално за шрифтовете на Arch
    if [ -f /etc/arch-release ]; then
        $INSTALL_CMD ttf-jetbrains-mono-nerd
    fi

    clear
    # Въпросът за Zsh в терминала
    echo -n "Do you want to make zsh the default shell? (y/N): "
    read -r answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" ]]; then
        echo "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi
}

BACKTITLE="Krisi's Dotfiles Installer"
HEIGHT=15
WIDTH=65

dialog --backtitle "$BACKTITLE" \
--title " Welcome! " \
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
"Zsh" "Shell configuration (.zshrc)" OFF 2> $TEMP_FILE

if [ $? -ne 0 ]; then
    rm $TEMP_FILE
    clear
    exit 0
fi

SELECTED=$(cat $TEMP_FILE)
rm $TEMP_FILE

clear
install_packages

dialog --backtitle "$BACKTITLE" \
--title " Finished " \
--msgbox "Installation completed successfully!\n\nPlease restart your session." 8 50

clear
reboot
