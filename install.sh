#!/bin/bash

# Сюда впиши свой ник на GitHub и название репозитория с дотфайлами
GITHUB_USER="твой_ник_на_github"
REPO_NAME="dotfiles"

# Ссылка для скачивания «сырых» файлов списков пакетов
RAW_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/main"

echo "=== Старт автоматической настройки системы из GitHub ==="

# 1. Обновляем систему
echo "Обновляю базу данных пакетов..."
sudo pacman -Syu --noconfirm

# 2. Ставим paru (AUR-помощник на Rust)
if ! command -v paru &> /dev/null; then
    echo "Устанавливаю paru..."
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru && makepkg -si --noconfirm
    cd -
fi

# 3. Скачиваем списки пакетов во временную папку и устанавливаем
mkdir -p /tmp/dotfiles-install

echo "Скачиваю списки пакетов..."
curl -sS "$RAW_URL/pacman_packages.txt" > /tmp/dotfiles-install/pacman_packages.txt
curl -sS "$RAW_URL/aur_packages.txt" > /tmp/dotfiles-install/aur_packages.txt

# Установка официальных пакетов
if [ -s /tmp/dotfiles-install/pacman_packages.txt ]; then
    echo "Устанавливаю официальные пакеты через pacman..."
    sudo pacman -S --needed --noconfirm - < /tmp/dotfiles-install/pacman_packages.txt
fi

# Установка AUR пакетов
if [ -s /tmp/dotfiles-install/aur_packages.txt ]; then
    echo "Устанавливаю пакеты из AUR через paru..."
    paru -S --needed --noconfirm - < /tmp/dotfiles-install/aur_packages.txt
fi

# 4. Клонируем конфиги и раскладываем по местам
echo "Выкачиваю конфигурационные файлы с GitHub..."
rm -rf /tmp/my-dotfiles-repo
git clone "https://github.com/$GITHUB_USER/$REPO_NAME.git" /tmp/my-dotfiles-repo

mkdir -p ~/.config
mkdir -p ~/.local/bin

echo "Раскладываю конфиги по папкам..."
# Переносим папки настроек из репозитория в ~/.config
for config_dir in hypr kitty waybar fuzzel swaync starship.toml; do
    if [ -e "/tmp/my-dotfiles-repo/$config_dir" ]; then
        cp -r "/tmp/my-dotfiles-repo/$config_dir" ~/.config/
    fi
done

# Переносим кастомные скрипты в ~/.local/bin
if [ -d "/tmp/my-dotfiles-repo/bin" ]; then
    cp -r "/tmp/my-dotfiles-repo/bin/"* ~/.local/bin/
    chmod +x ~/.local/bin/*
fi

# Очистка временных файлов
rm -rf /tmp/dotfiles-install
rm -rf /tmp/my-dotfiles-repo

echo "=== Настройка успешно завершена! Можно запускать Hyprland ==="
