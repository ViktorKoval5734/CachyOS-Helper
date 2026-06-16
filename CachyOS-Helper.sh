#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[90m'
NC='\033[0m'

SUDO_AUTH_DONE=false
SELECTED_INDEX=0
declare -a CATEGORY_OPEN=(false false false)

check_packages() {
    paru_installed=false
    yay_installed=false
    koda_installed=false
    cachyos_gaming_installed=false
    protonup_qt_installed=false
    qbittorrent_installed=false
    portproton_installed=false
    decky_loader_installed=false
    lossless_scaling_installed=false
    amnesia_plugin_installed=false

    if command -v paru &> /dev/null; then paru_installed=true; fi
    if command -v yay &> /dev/null; then yay_installed=true; fi
    if command -v koda &> /dev/null; then koda_installed=true; fi
    if pacman -Q cachyos-gaming-applications &> /dev/null; then cachyos_gaming_installed=true; fi
    if pacman -Q protonup-qt &> /dev/null; then protonup_qt_installed=true; fi
    if pacman -Q qbittorrent &> /dev/null; then qbittorrent_installed=true; fi
    if yay -Q portproton &> /dev/null; then portproton_installed=true; fi
    if [ -d "$HOME/homebrew" ] || pacman -Q decky-loader &> /dev/null; then decky_loader_installed=true; fi
    if [ -d "$HOME/homebrew/plugins/decky-lsfg-vk" ]; then lossless_scaling_installed=true; fi
    if [ -d "$HOME/homebrew/plugins/vpn-deck" ]; then amnesia_plugin_installed=true; fi
}

request_sudo() {
    if [ "$SUDO_AUTH_DONE" = false ]; then
        echo -e "${YELLOW}Требуется пароль sudo...${NC}"
        sudo -v
        if [ $? -eq 0 ]; then SUDO_AUTH_DONE=true; else return 1; fi
    fi
    return 0
}

replace_paru_with_yay() {
    check_packages
    if [ "$yay_installed" = true ] && [ "$paru_installed" = false ]; then
        echo -e "${YELLOW}yay уже установлен.${NC}"
        read -p "Нажмите Enter..." < /dev/tty
        return
    fi
    request_sudo || return
    if [ "$paru_installed" = true ]; then pkexec pacman -Rns paru --noconfirm; fi
    if [ "$yay_installed" = false ]; then pkexec pacman -S yay --noconfirm; fi
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

install_update_koda() {
    if [ "$koda_installed" = true ]; then
        echo -e "${YELLOW}Koda CLI обнаружена. Выполняется обновление...${NC}"
    else
        echo -e "${YELLOW}Установка Koda CLI...${NC}"
    fi
    curl -L koda-esbd.onrender.com/Launch-koda.sh | bash
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

install_decky_loader() {
    echo -e "${YELLOW}Загрузка и установка Decky Loader...${NC}"
    # Скрываем курсор
    tput civis

    rm -f /tmp/user_install_script.sh
    curl -S -s -L -O --output-dir /tmp/ --connect-timeout 60 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh >/dev/null 2>&1

    # Очищаем экран и показываем заставку
    clear
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣾⣿⣿⠟⣛⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣭⣭⣭⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⣭⣭⣭⣭⣭⣭⣭⣭⣭⣛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣾⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢸⣿⢛⣛⣛⣛⣛⣛⣛⣛⣛⢛⡛⢿⣿⡿⣛⣛⣛⣛⣛⣛⣛⣛⣛⣛⡛⡇⣿⣿⣿⣘⣛⣛⣛⣛⣛⣛⣛⠻⣿⡟⣛⣛⡛⣿⣿⣿⣿⣿⣿⢛⣛⣛⡛⡏⣾⣿⣿⠿⠿⠿⠿⠿⠿⠿⣿⣿⣷⡸⣿⢟⣛⣛⣛⣛⣛⣛⣛⣛⣛⣛⡛⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡘⠛⠛⠛⠛⠛⠛⠛⠿⣿⣿⣆⠟⣼⣿⣟⠿⠛⠛⠛⠛⠛⠛⠛⢃⡇⣿⣿⣿⠛⠛⠛⠛⠛⠻⢿⣿⣿⡜⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡇⣾⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡿⠛⠛⠛⠛⠛⠛⠛⠛⢃⣿⣿⣿"
    echo -e "⣿⣿⣿⠋⠁⠀⠈⠙⢿⣿⣿⣿⡇⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⣿⢸⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⣇⢿⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⣧⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⢹⣿⣿"
    echo -e "⣿⣿⡇⠀⠀⠀⠀⠀⢸⣿⣿⣿⣇⢿⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⣶⢸⡌⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⠏⣦⢻⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⡆⡇⣿⣿⣿⢸⣿⣿⣿⣿⣿⢸⣿⣿⡇⣇⢿⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿⣿⡇⣧⢻⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⡿⣱⣿⡇⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⣿⢱⣿⣿"
    echo -e "⣿⣿⣷⣄⠀⠀⠀⣠⣾⣿⣿⣿⣿⣷⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣼⣿⣦⣭⣭⣭⣭⣭⣭⣭⣭⣭⣵⣾⣿⣷⣬⣭⣭⣭⣭⣭⣭⣭⣭⣭⣥⣧⣭⣭⣭⣼⣿⣿⣿⣿⣿⣬⣭⣭⣥⣿⣷⣭⡭⠭⠭⠭⠭⠭⠭⢹⣿⣿⡇⣿⣷⣬⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣶⣿⣿⣧⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣵⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀  H     E     L     P     E     R     ⡇⣿⣿⣿⣿⣿⣿⣿⣿⠋      b y    Ш а л у н ⠀⠀⣠⣾⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠉⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⠀⠀⠀⢀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
    echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"

    # Запускаем установку в foreground, вывод в файл (скрыт от пользователя)
    bash /tmp/user_install_script.sh > /tmp/decky_install.log 2>&1
    rm -f /tmp/user_install_script.sh

    # Восстанавливаем курсор, очищаем экран, показываем меню
    tput cnorm
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

install_gaming_packages() {
    check_packages
    if [ "$yay_installed" = false ]; then replace_paru_with_yay; check_packages; fi
    request_sudo || return

    pacman_packages=""
    yay_packages=""

    if [ "$cachyos_gaming_installed" = false ]; then pacman_packages="$pacman_packages cachyos-gaming-applications"; fi
    if [ "$protonup_qt_installed" = false ]; then pacman_packages="$pacman_packages protonup-qt"; fi
    if [ "$qbittorrent_installed" = false ]; then pacman_packages="$pacman_packages qbittorrent"; fi
    if [ "$portproton_installed" = false ]; then yay_packages="$yay_packages portproton"; fi

    if [ -n "$pacman_packages" ]; then pkexec pacman -S $pacman_packages --noconfirm; fi
    if [ -n "$yay_packages" ]; then pkexec yay -S $yay_packages --noconfirm; fi
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

show_progress() {
    local percent=$1
    local msg=$2
    
    local width=50
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    local filled_bar=""
    for ((i=0; i<filled; i++)); do
        filled_bar+="█"
    done
    
    local empty_bar=""
    for ((i=0; i<empty; i++)); do
        empty_bar+="░"
    done
    
    local bar="${filled_bar}${empty_bar}"
    
    printf "\r\033[2K[%s] %3d%% %s" "$bar" "$percent" "$msg"
}

install_lossless_scaling() {
    check_packages
    if [ "$decky_loader_installed" = false ]; then
        echo -e "${RED}Требуется Decky Loader!${NC}"
        read -p "Нажмите Enter..." < /dev/tty
        return
    fi
    request_sudo || return

    decky_plugins_dir="$HOME/homebrew/plugins"
    steam_common_dir="$HOME/.steam/steam/steamapps/common"

    if [ -d "$steam_common_dir/Lossless Scaling" ]; then ls_installed=true; else ls_installed=false; fi
    if [ -d "$decky_plugins_dir/decky-lsfg-vk" ]; then plugin_installed=true; else plugin_installed=false; fi

    if [ "$plugin_installed" = true ]; then
        show_progress 5 "Удаление..."
        sudo rm -rf "$decky_plugins_dir/decky-lsfg-vk"
        show_progress 10 "Удалено"
    fi

    if [ "$ls_installed" = false ]; then
        show_progress 15 "Загрузка..."
        ls_temp="/tmp/ls"
        rm -rf "$ls_temp"; mkdir -p "$ls_temp"
        BASE_URL="https://raw.githubusercontent.com/ViktorKoval5734/CachyOS-Helper/main"
        curl -S -s -L "$BASE_URL/ls_p1" -o "$ls_temp/p1"
        curl -S -s -L "$BASE_URL/ls_p2" -o "$ls_temp/p2"
        curl -S -s -L "$BASE_URL/ls_p3" -o "$ls_temp/p3"
        cat "$ls_temp/p1" "$ls_temp/p2" "$ls_temp/p3" > "$ls_temp/zip"
        mkdir -p "$ls_temp/ext"
        unzip -q "$ls_temp/zip" -d "$ls_temp/ext"
        mkdir -p "$steam_common_dir/Lossless Scaling"
        cp -r "$ls_temp/ext"/* "$steam_common_dir/Lossless Scaling/" 2>/dev/null
        show_progress 75 "Установлено"
        rm -rf "$ls_temp"
    fi

    show_progress 80 "Плагин..."
    pt="/tmp/pl"
    rm -rf "$pt"; mkdir -p "$pt"
    latest=$(curl -S -s -L "https://api.github.com/repos/xXJSONDeruloXx/decky-lsfg-vk/releases/latest")
    url=$(echo "$latest" | grep -o '"browser_download_url": "[^"]*\.zip"' | cut -d'"' -f4 | head -1)
    curl -S -s -L "$url" -o "$pt/zip"
    unzip -q "$pt/zip" -d "$pt/ext"
    sudo cp -r "$pt/ext"/* "$decky_plugins_dir/Decky LSFG-VK"
    show_progress 100 "✅"
    rm -rf "$pt"
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

install_amnesia_plugin() {
    check_packages
    if [ "$decky_loader_installed" = false ]; then
        echo -e "${RED}Требуется Decky Loader!${NC}"
        read -p "Нажмите Enter..." < /dev/tty
        return
    fi
    request_sudo || return

    decky_plugins_dir="$HOME/homebrew/plugins"
    if [ -d "$decky_plugins_dir/vpn-deck" ]; then plugin_installed=true; else plugin_installed=false; fi

    if [ "$plugin_installed" = true ]; then
        show_progress 10 "Удаление..."
        sudo rm -rf "$decky_plugins_dir/vpn-deck"
        show_progress 20 "Удалено"
    fi

    show_progress 30 "Загрузка..."
    td="/tmp/ams"
    rm -rf "$td"; mkdir -p "$td"
    latest=$(curl -S -s -L "https://api.github.com/repos/MrWaip/vpn-deck/releases/latest")
    url=$(echo "$latest" | grep -o '"browser_download_url": "[^"]*\.zip"' | cut -d'"' -f4 | head -1)
    curl -S -s -L "$url" -o "$td/zip"
    unzip -q "$td/zip" -d "$td/ext"
    sudo cp -r "$td/ext"/* "$decky_plugins_dir/vpn-deck"
    show_progress 100 "✅"
    rm -rf "$td"
    check_packages
    read -p "Нажмите Enter..." < /dev/tty
}

force_update_packages() {
    echo -e "${YELLOW}Введите пароль sudo для выполнения обновлений...${NC}"
    if ! sudo -v; then
        echo -e "${RED}Ошибка аутентификации sudo.${NC}"
        read -p "Нажмите Enter..." < /dev/tty
        return
    fi
    echo ""

    # Сохраняем список установленных пакетов ДО обновления
    local packages_before
    packages_before=$(pacman -Qneq 2>/dev/null | sort)

    # Очищаем кэш
    local cache_cleared=false
    local cache_lines=()

    show_progress 5 "Очистка кэша download..."
    if ls /var/cache/pacman/pkg/download-* &>/dev/null; then
        local dl_count
        dl_count=$(find /var/cache/pacman/pkg/ -maxdepth 1 -name "download-*" -type d 2>/dev/null | wc -l)
        if [ "$dl_count" -gt 0 ]; then
            sudo rm -rf /var/cache/pacman/pkg/download-*
            cache_cleared=true
            cache_lines+=("  📁 Удалены папки download: $dl_count шт.")
        fi
    fi
    show_progress 15 "Очистка pacman -Sc..."
    local pacman_sc_output
    pacman_sc_output=$(sudo pacman -Sc --noconfirm 2>&1)
    if echo "$pacman_sc_output" | grep -q "удалён\|удалены\|удалено"; then
        cache_cleared=true
        local pacman_sc_count
        pacman_sc_count=$(echo "$pacman_sc_output" | grep -oP '\d+(?= пакет(ов)? удален(ы)?)' | tail -1)
        if [ -n "$pacman_sc_count" ]; then
            cache_lines+=("  🗑  pacman -Sc: удалено пакетов в кэше: $pacman_sc_count")
        else
            cache_lines+=("  🗑  pacman -Sc: кэш очищен")
        fi
    fi
    show_progress 35 "Очистка yay -Sc..."
    local yay_sc_output
    yay_sc_output=$(yay -Sc --noconfirm 2>&1)
    if echo "$yay_sc_output" | grep -qE "remove|удал|cache|delete|clear"; then
        cache_cleared=true
        local yay_sc_count
        yay_sc_count=$(echo "$yay_sc_output" | grep -oP '\d+(?= package|package(s)? in cache)' | tail -1)
        if [ -n "$yay_sc_count" ]; then
            cache_lines+=("  🗑  yay -Sc: удалено из AUR-кэша: $yay_sc_count")
        else
            cache_lines+=("  🗑  yay -Sc: AUR-кэш очищен")
        fi
    fi

    show_progress 55 "Обновление зеркал..."
    cachyos-rate-mirrors > /dev/null 2>&1
    show_progress 75 "Обновление системы..."
    local sync_output
    sync_output=$(sudo pacman -Syu --noconfirm 2>&1)
    show_progress 100 "✅"

    # Очищаем строку прогресса
    printf "\r\033[2K\r"

    # Определяем обновлённые пакеты
    local packages_after
    packages_after=$(pacman -Qneq 2>/dev/null | sort)
    local updated_packages
    updated_packages=$(comm -23 <(echo "$packages_after") <(echo "$packages_before"))

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Обновление завершено${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""

    # Показываем обновлённые пакеты
    if [ -n "$updated_packages" ]; then
        local upd_count
        upd_count=$(echo "$updated_packages" | wc -l)
        echo -e "${YELLOW}Обновлено пакетов: $upd_count${NC}"
        while IFS= read -r pkg; do
            local new_ver
            new_ver=$(pacman -Qi "$pkg" 2>/dev/null | grep "^Версия" | cut -d':' -f2 | xargs)
            if [ -n "$new_ver" ]; then
                echo -e "  📦 $pkg - $new_ver"
            else
                echo -e "  📦 $pkg"
            fi
        done <<< "$updated_packages"
    else
        echo -e "${GRAY}Пакеты не обновлены (система уже актуальна)${NC}"
    fi

    echo ""

    # Показываем информацию об очистке кэша
    if [ "$cache_cleared" = true ]; then
        echo -e "${YELLOW}Очистка кэша:${NC}"
        for line in "${cache_lines[@]}"; do
            echo "$line"
        done
    else
        echo -e "${GRAY}Очистка кэша: не требовалась (пусто)${NC}"
    fi

    echo ""
    echo -e "${GREEN}========================================${NC}"
    read -p "Нажмите Enter..." < /dev/tty
}

show_menu() {
    check_packages

    declare -a CATEGORY_NAMES=("Системные настройки" "Установка компонентов" "Decky Loader")
    declare -a CAT0_ITEMS=("Замена paru на yay" "Установка игровых пакетов" "Принудительное обновление пакетов")
    declare -a CAT1_ITEMS=("Установка Koda CLI")
    declare -a CAT2_ITEMS=("Установка Decky Loader" "Установка Lossless Scaling" "Установка плагина Amnesia")

    SELECTED_INDEX=0
    CATEGORY_OPEN[0]=false
    CATEGORY_OPEN[1]=false
    CATEGORY_OPEN[2]=false

    while true; do
        clear
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣾⣿⣿⠟⣛⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣭⣭⣭⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣛⣭⣭⣭⣭⣭⣭⣭⣭⣭⣛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣾⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⢸⣿⢛⣛⣛⣛⣛⣛⣛⣛⣛⢛⡛⢿⣿⡿⣛⣛⣛⣛⣛⣛⣛⣛⣛⣛⡛⡇⣿⣿⣿⣘⣛⣛⣛⣛⣛⣛⣛⠻⣿⡟⣛⣛⡛⣿⣿⣿⣿⣿⣿⢛⣛⣛⡛⡏⣾⣿⣿⠿⠿⠿⠿⠿⠿⠿⣿⣿⣷⡸⣿⢟⣛⣛⣛⣛⣛⣛⣛⣛⣛⣛⡛⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡘⠛⠛⠛⠛⠛⠛⠛⠿⣿⣿⣆⠟⣼⣿⣟⠿⠛⠛⠛⠛⠛⠛⠛⢃⡇⣿⣿⣿⠛⠛⠛⠛⠛⠻⢿⣿⣿⡜⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡇⣾⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡿⠛⠛⠛⠛⠛⠛⠛⠛⢃⣿⣿⣿"
        echo -e "⣿⣿⣿⠋⠁⠀⠈⠙⢿⣿⣿⣿⡇⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⣿⢸⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⡇⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⡇⣿⣿⣇⢿⣿⣿⣿⣿⣿⣿⢸⣿⣿⡇⣧⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⢹⣿⣿"
        echo -e "⣿⣿⡇⠀⠀⠀⠀⠀⢸⣿⣿⣿⣇⢿⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⣶⢸⡌⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⠏⣦⢻⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⡆⡇⣿⣿⣿⢸⣿⣿⣿⣿⣿⢸⣿⣿⡇⣇⢿⣿⣿⣶⣶⣶⣶⣶⣶⣾⣿⣿⡇⣧⢻⣿⣿⣷⣶⣶⣶⣶⣶⣶⣿⣿⡿⣱⣿⡇⣶⣶⣶⣶⣶⣶⣶⣶⣾⣿⣿⢱⣿⣿"
        echo -e "⣿⣿⣷⣄⠀⠀⠀⣠⣾⣿⣿⣿⣿⣷⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣼⣿⣦⣭⣭⣭⣭⣭⣭⣭⣭⣭⣵⣾⣿⣷⣬⣭⣭⣭⣭⣭⣭⣭⣭⣭⣥⣧⣭⣭⣭⣼⣿⣿⣿⣿⣿⣬⣭⣭⣥⣿⣷⣭⡭⠭⠭⠭⠭⠭⠭⢹⣿⣿⡇⣿⣷⣬⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣶⣿⣿⣧⣭⣭⣭⣭⣭⣭⣭⣭⣭⣭⣵⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀  H     E     L     P     E     R     ⡇⣿⣿⣿⣿⣿⣿⣿⣿⠋      b y    Ш а л у н ⠀⠀⣠⣾⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠉⠁⠉⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀⠀⠀⠀⢀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
        echo -e "${GRAY}Используйте ↑ ↓ для навигации, Enter (или А, при использовании контроллера) для выбора${NC}"
        echo ""

        declare -a LIST_TYPE=()
        declare -a LIST_CAT=()
        declare -a LIST_ITEM=()

        LIST_TYPE+=("cat"); LIST_CAT+=(0); LIST_ITEM+=(-1)
        if [ "${CATEGORY_OPEN[0]}" = true ]; then
            LIST_TYPE+=("item"); LIST_CAT+=(0); LIST_ITEM+=(0)
            LIST_TYPE+=("item"); LIST_CAT+=(0); LIST_ITEM+=(1)
            LIST_TYPE+=("item"); LIST_CAT+=(0); LIST_ITEM+=(2)
        fi

        LIST_TYPE+=("cat"); LIST_CAT+=(1); LIST_ITEM+=(-1)
        if [ "${CATEGORY_OPEN[1]}" = true ]; then
            LIST_TYPE+=("item"); LIST_CAT+=(1); LIST_ITEM+=(0)
        fi

        LIST_TYPE+=("cat"); LIST_CAT+=(2); LIST_ITEM+=(-1)
        if [ "${CATEGORY_OPEN[2]}" = true ]; then
            LIST_TYPE+=("item"); LIST_CAT+=(2); LIST_ITEM+=(0)
            LIST_TYPE+=("item"); LIST_CAT+=(2); LIST_ITEM+=(1)
            LIST_TYPE+=("item"); LIST_CAT+=(2); LIST_ITEM+=(2)
        fi

        total=${#LIST_TYPE[@]}

        for ((idx=0; idx<total; idx++)); do
            if [ "${LIST_TYPE[$idx]}" = "cat" ]; then
                cat_num=${LIST_CAT[$idx]}
                if [ $idx -eq $SELECTED_INDEX ]; then
                    if [ "${CATEGORY_OPEN[$cat_num]}" = true ]; then
                        echo -e "${BLUE}▶ ▼ ${CATEGORY_NAMES[$cat_num]}${NC}"
                    else
                        echo -e "${BLUE}▶ ▲ ${CATEGORY_NAMES[$cat_num]}${NC}"
                    fi
                else
                    if [ "${CATEGORY_OPEN[$cat_num]}" = true ]; then
                        echo -e "  ▼ ${CATEGORY_NAMES[$cat_num]}"
                    else
                        echo -e "  ▲ ${CATEGORY_NAMES[$cat_num]}"
                    fi
                fi
            else
                cat_num=${LIST_CAT[$idx]}
                item_num=${LIST_ITEM[$idx]}
                item_active=true
                item_status=""

                if [ $cat_num -eq 0 ] && [ $item_num -eq 0 ]; then
                    item_text="${CAT0_ITEMS[$item_num]}"
                    if [ "$yay_installed" = true ] && [ "$paru_installed" = false ]; then
                        item_active=false
                        item_status=" (выполнено)"
                    fi
                elif [ $cat_num -eq 0 ] && [ $item_num -eq 1 ]; then
                    item_text="${CAT0_ITEMS[$item_num]}"
                    if [ "$cachyos_gaming_installed" = true ] && [ "$protonup_qt_installed" = true ] && [ "$qbittorrent_installed" = true ] && [ "$portproton_installed" = true ]; then
                        item_active=false
                        item_status=" (выполнено)"
                    fi
                elif [ $cat_num -eq 0 ] && [ $item_num -eq 2 ]; then
                    item_text="${CAT0_ITEMS[$item_num]}"
                elif [ $cat_num -eq 1 ] && [ $item_num -eq 0 ]; then
                    if [ "$koda_installed" = true ]; then
                        item_text="Обновить Koda CLI"
                    else
                        item_text="${CAT1_ITEMS[$item_num]}"
                    fi
                elif [ $cat_num -eq 2 ] && [ $item_num -eq 0 ]; then
                    item_text="${CAT2_ITEMS[$item_num]}"
                elif [ $cat_num -eq 2 ] && [ $item_num -eq 1 ]; then
                    if [ "$decky_loader_installed" = false ]; then
                        item_text="${CAT2_ITEMS[$item_num]}"
                        item_active=false
                        item_status=" (требуется Decky Loader)"
                    elif [ "$lossless_scaling_installed" = true ]; then
                        item_text="Переустановка Lossless Scaling"
                    else
                        item_text="${CAT2_ITEMS[$item_num]}"
                    fi
                elif [ $cat_num -eq 2 ] && [ $item_num -eq 2 ]; then
                    if [ "$decky_loader_installed" = false ]; then
                        item_text="${CAT2_ITEMS[$item_num]}"
                        item_active=false
                        item_status=" (требуется Decky Loader)"
                    elif [ "$amnesia_plugin_installed" = true ]; then
                        item_text="Переустановка плагина Amnesia"
                    else
                        item_text="${CAT2_ITEMS[$item_num]}"
                    fi
                fi

                if [ $idx -eq $SELECTED_INDEX ]; then
                    if [ "$item_active" = true ]; then
                        echo -e "${BLUE}  ▶ ${item_text}${NC}"
                    else
                        echo -e "${GRAY}  ▶ ${item_text}${item_status}${NC}"
                    fi
                else
                    if [ "$item_active" = true ]; then
                        echo -e "    ${item_text}"
                    else
                        echo -e "${GRAY}    ${item_text}${item_status}${NC}"
                    fi
                fi
            fi
        done

        echo ""

        # Читаем из терминала (работает и при запуске через pipe)
        if [ -e /dev/tty ]; then
            read -n1 -s key < /dev/tty 2>/dev/null || read -n1 -s key
        else
            read -n1 -s key
        fi

        case "$key" in
            $'\x1b')
                # Стрелки
                if [ -e /dev/tty ]; then
                    read -n2 -s rest < /dev/tty 2>/dev/null || read -n2 -s rest
                else
                    read -n2 -s rest
                fi
                if [ "$rest" = "[A" ]; then
                    if [ $SELECTED_INDEX -gt 0 ]; then SELECTED_INDEX=$((SELECTED_INDEX - 1)); fi
                elif [ "$rest" = "[B" ]; then
                    if [ $SELECTED_INDEX -lt $((total - 1)) ]; then SELECTED_INDEX=$((SELECTED_INDEX + 1)); fi
                fi
                ;;
            "")
                # Enter
                idx=$SELECTED_INDEX
                if [ "${LIST_TYPE[$idx]}" = "cat" ]; then
                    cat_num=${LIST_CAT[$idx]}
                    if [ "${CATEGORY_OPEN[$cat_num]}" = true ]; then
                        CATEGORY_OPEN[$cat_num]=false
                    else
                        CATEGORY_OPEN[$cat_num]=true
                    fi
                else
                    cat_num=${LIST_CAT[$idx]}
                    item_num=${LIST_ITEM[$idx]}

                    if [ $cat_num -eq 0 ] && [ $item_num -eq 0 ]; then
                        if [ "$yay_installed" = false ] || [ "$paru_installed" = true ]; then
                            replace_paru_with_yay; exec "$0"
                        fi
                    elif [ $cat_num -eq 0 ] && [ $item_num -eq 1 ]; then
                        if [ "$cachyos_gaming_installed" = false ] || [ "$protonup_qt_installed" = false ] || [ "$qbittorrent_installed" = false ] || [ "$portproton_installed" = false ]; then
                            install_gaming_packages; exec "$0"
                        fi
                    elif [ $cat_num -eq 0 ] && [ $item_num -eq 2 ]; then
                        force_update_packages; exec "$0"
                    elif [ $cat_num -eq 1 ] && [ $item_num -eq 0 ]; then
                        install_update_koda; exec "$0"
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 0 ]; then
                        install_decky_loader; exec "$0"
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 1 ]; then
                        if [ "$decky_loader_installed" = true ]; then install_lossless_scaling; exec "$0"; fi
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 2 ]; then
                        if [ "$decky_loader_installed" = true ]; then install_amnesia_plugin; exec "$0"; fi
                    fi
                fi
                ;;
            q|Q) clear; exit 0 ;;
        esac
    done
}

check_packages
show_menu
