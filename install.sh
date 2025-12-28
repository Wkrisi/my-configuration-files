#!/usr/bin/env bash

if [ -f /etc/NIXOS ] && ! command -v dialog &> /dev/null; then
    exec nix-shell -p dialog --run "$(printf "%q " "$0" "$@")"
fi

# Дефинираме функцията, но ще я извикаме по-късно
install_packages() {
    if [ -f /etc/arch-release ]; then
        echo "Updating system and installing base dependencies..."
        sudo pacman -S --noconfirm dialog wlogout swww waybar hyprland

        if [[ $SELECTED == *"Hyprland"* ]]; then
            echo "Configuring Hyprland..."
            sudo pacman -S --noconfirm hyprland
        fi
        
        if [[ $SELECTED == *"Waybar"* ]]; then
            echo "Configuring Waybar..."
            sudo pacman -S --noconfirm waybar
        fi
    fi

    sudo pacman -S --noconfirm swync
    sudo pacman -S --noconfirm wlsunset
    sudo pacman -S --noconfirm thunar
    sudo pacman -S --noconfirm wlogout
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

# Поправен checklist блок
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

# Първо проверяваме дали изобщо имаме dialog (за всеки случай)
if ! command -v dialog &> /dev/null && [ ! -f /etc/NIXOS ]; then
    if [ -f /etc/arch-release ]; then
        sudo pacman -S --noconfirm dialog
    fi
fi

# Извикваме инсталацията СЛЕД като вече знаем какво е избрано
install_packages

echo "Installing selected components: $SELECTED"

# Тук можеш да сложиш твоя git clone
# git clone https://github.com/Wkrisi/my-configuration-files.git

dialog --backtitle "$BACKTITLE" \
--title " Finished " \
--msgbox "Installation completed successfully!\n\nPlease restart your session." 8 50

clear
