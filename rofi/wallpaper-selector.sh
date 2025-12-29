#!/usr/bin/env bash

# ВАЖНО: Проверете дали този път е 100% точен
WALLPAPER_DIR="$HOME/Pictures/wallpapers/"

# Влизаме в директорията, за да няма проблеми с пътищата
cd "$WALLPAPER_DIR" || exit

# Избираме файл - поддържа jpg, png и jpeg
SELECTION=$(ls *.jpg *.png *.jpeg 2>/dev/null | rofi -dmenu -i -p "Избери тапет")

# Проверка дали потребителят е избрал нещо
if [ -n "$SELECTION" ]; then
    # Пълен път до избрания файл
    FULL_PATH="$WALLPAPER_DIR/$SELECTION"

    # Опит за задаване на тапет (пробват се няколко инструмента)
    if command -v swww >/dev/null; then
        swww img "$FULL_PATH" && wal -i "$FULL_PATH"
    elif command -v feh >/dev/null; then
        feh --bg-fill "$FULL_PATH"
    else
        notify-send "Грешка" "Нито feh, нито swww са намерени!"
    fi
else
    echo "Нищо не е избрано."
fi
