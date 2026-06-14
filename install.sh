#!/bin/bash

# Каталог, где лежит сам скрипт и файлы со списками
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Старт автоматической настройки системы (Paru Edition) ==="

# 1. Обновляем систему
echo "Обновляю систему..."
sudo pacman -Syu --noconfirm

# 2. Ставим paru, если его еще нет
if ! command -v paru &> /dev/null; then
    echo "Устанавливаю paru (AUR-помощник на Rust)..."
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd "$BASE_DIR"
fi

# 3. Установка официальных пакетов из pacman_packages.txt
if [ -f "$BASE_DIR/pacman_packages.txt" ]; then
    echo "Устанавливаю официальные пакеты через pacman..."
    sudo pacman -S --needed --noconfirm - < "$BASE_DIR/pacman_packages.txt"
else
    echo "Ошибка: Файл pacman_packages.txt не найден!"
fi

# 4. Установка AUR пакетов из aur_packages.txt с помощью paru
if [ -f "$BASE_DIR/aur_packages.txt" ]; then
    echo "Устанавливаю пакеты из AUR через paru..."
    # Флаг --noconfirm отключает лишние вопросы, но paru всё равно покажет PKGBUILD, если это критично.
    paru -S --needed --noconfirm - < "$BASE_DIR/aur_packages.txt"
else
    echo "Ошибка: Файл aur_packages.txt не найден!"
fi

# 5. Копируем конфиги на их законные места
echo "Раскладываю конфигурационные файлы..."
mkdir -p ~/.config
mkdir -p ~/.local/bin

# Копируем папки настроек
for config_dir in hypr kitty waybar fuzzel swaync starship.toml; do
    if [ -e "$BASE_DIR/$config_dir" ]; then
        cp -r "$BASE_DIR/$config_dir" ~/.config/
    fi
done

# Копируем наши кастомные скрипты (включая смену обоев)
if [ -d "$BASE_DIR/bin" ]; then
    cp -r "$BASE_DIR/bin/"* ~/.local/bin/
    chmod +x ~/.local/bin/*
fi

echo "=== Настройка успешно завершена! Можно запускать Hyprland ==="
