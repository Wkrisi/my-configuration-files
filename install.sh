#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ -f /etc/NIXOS ] && ! command -v dialog &> /dev/null; then
    exec nix-shell -p dialog --run "$(printf "%q " "$0" "$@")"
fi

install_packages() {
    if [ -f /etc/arch-release ]; then
        INSTALL_CMD="sudo pacman -S --noconfirm"
        
        if ! command -v paru &> /dev/null; then
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            cd /tmp/paru && makepkg -si --noconfirm
            cd "$SCRIPT_DIR"
        fi
    elif [ -f /etc/NIXOS ]; then
        INSTALL_CMD="nix-env -iA nixos"
    else
        exit 1
    fi

    $INSTALL_CMD dialog wlogout swww swaync kitty thunar hyprlock hypridle lsd fzf \
                pavucontrol zoxide cava nwg-look xdg-desktop-portal-hyprland \
                imagemagick grim slurp dolphin hyprshot

    if [ -f /etc/arch-release ]; then
        printf "1\n" | paru -S --noconfirm python-pywal16
    else
        $INSTALL_CMD python-pywal
    fi

    mkdir -p "$HOME/.config"

    if [[ $SELECTED == *"Hyprland"* ]]; then
        mkdir -p "$HOME/.config/hypr"
        if [ -d "$SCRIPT_DIR/hypr" ]; then
            cp -rf "$SCRIPT_DIR/hypr/." "$HOME/.config/hypr/"
        else
            cp -f "$SCRIPT_DIR/hyprland.conf" "$HOME/.config/hypr/"
        fi
    fi
    
    if [[ $SELECTED == *"Waybar"* ]]; then
        rm -rf "$HOME/.config/waybar"
        cp -rf "$SCRIPT_DIR/waybar" "$HOME/.config/"
        [ -f "$HOME/.config/waybar/cava.sh" ] && chmod +x "$HOME/.config/waybar/cava.sh"
    fi

    if [[ $SELECTED == *"Rofi"* ]]; then
        $INSTALL_CMD rofi
        rm -rf "$HOME/.config/rofi"
        mkdir -p "$HOME/.config/rofi"
        cp -rf "$SCRIPT_DIR/rofi/." "$HOME/.config/rofi/"
    fi

    if [[ $SELECTED == *"Zsh"* ]]; then
        $INSTALL_CMD zsh
        cp -f "$SCRIPT_DIR/.zshrc" "$HOME/"
    fi

    if [ -f /etc/arch-release ]; then
        $INSTALL_CMD ttf-jetbrains-mono-nerd
    fi

    clear
    echo -n "Do you want to make zsh the default shell? (y/N): "
    read -r answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

    if [[ "$answer" == "y" ]]; then
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
"Hyprland" "Window Manager config" OFF \
"Waybar" "Status bar theme" OFF \
"Zsh" "Shell configuration (.zshrc)" OFF \
"Rofi" "Application manager" OFF 2> $TEMP_FILE

if [ $? -ne 0 ]; then
    rm "$TEMP_FILE"
    clear
    exit 0
fi

SELECTED=$(cat "$TEMP_FILE")
rm "$TEMP_FILE"

clear
install_packages

dialog --backtitle "$BACKTITLE" \
--title " Finished " \
--yesno "Installation completed successfully!\n\nDo you want to reboot now?" 8 50

if [ $? -eq 0 ]; then
    clear
    sleep 1
    reboot
else
    clear
    exit 0
fi
