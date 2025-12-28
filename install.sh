#!/usr/bin/env bash

if [ -f /etc/NIXOS ] && ! command -v dialog &> /dev/null; then
    exec nix-shell -p dialog --run "$(printf "%q " "$0" "$@")"
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

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
    $INSTALL_CMD dialog wlogout swww waybar hyprland swaync kitty thunar hyprlock hypridle lsd fzf pavucontrol --needed base-devel
    git clone https://aur.archlinux.org/paru.git ~/Documents/
    makepkg -si ~/Documents/paru

 
if [[ $SELECTED == *"Hyprland"* ]]; then
        echo "Installing Hyprland configs..."
        # Приемаме, че имаш папка 'hypr' или файл 'hyprland.conf' в репозиторито
        mkdir -p "$HOME/.config/hypr"
        cp -rf "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/" 2>/dev/null || cp -rf "$SCRIPT_DIR/hypr/" "$HOME/.config/"
    fi
    
    if [[ $SELECTED == *"Waybar"* ]]; then
        echo "Installing Waybar configs..."
        cp -rf "$SCRIPT_DIR/waybar" "$HOME/.config/"
        chmod +x ~/.config/waybar/cava.sh
    fi


    if [[ $SELECTED == *"Zsh"* ]]; then
        echo "Installing Zsh config..."
        cp -f "$SCRIPT_DIR/.zshrc" "$HOME/"
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
--yesno "Installation completed successfully!\n\nPlease restart your session." 8 50

if [[ $? -ne 0 ]]; then
  clear
  exit 0
fi

clear
reboot
