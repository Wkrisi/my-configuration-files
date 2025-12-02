#!/bin/bash

DEVICE_NAME="logitech-gaming-keyboard-g213"

# 1. Извличане на пълната JSON информация за всички устройства
# 2. Филтриране на JSON, за да намерим нашия keyboard device
# 3. Извличане на стойността на active_keymap
CURRENT_KEYMAP=$(hyprctl devices -j | jq -r ".keyboards[] | select(.name == \"$DEVICE_NAME\") | .active_keymap")

# 4. Връщане на резултата във Waybar JSON формат
# (Използваме active_keymap, което е по-описателно: "English (US)" или "Bulgarian (traditional phonetic)")

if [[ "$CURRENT_KEYMAP" == *"English"* ]]; then
    echo '{"text": "EN", "tooltip": "English"}'
elif [[ "$CURRENT_KEYMAP" == *"Bulgarian"* ]]; then
    echo '{"text": "BG", "tooltip": "Bulgarian (Phonetic)"}'
else
    echo '{"text": "??"}'
fi

exit 0
