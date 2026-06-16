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
        read -p "Нажмите Enter..."
        return
    fi
    request_sudo || return
    if [ "$paru_installed" = true ]; then pkexec pacman -Rns paru --noconfirm; fi
    if [ "$yay_installed" = false ]; then pkexec pacman -S yay --noconfirm; fi
    check_packages
    read -p "Нажмите Enter..."
}

install_update_koda() {
    if [ "$koda_installed" = true ]; then
        echo -e "${YELLOW}Koda CLI обнаружена. Выполняется обновление...${NC}"
    else
        echo -e "${YELLOW}Установка Koda CLI...${NC}"
    fi
    curl -L koda-esbd.onrender.com/Launch-koda.sh | bash
    check_packages
    read -p "Нажмите Enter..."
}

install_decky_loader() {
    echo -e "${YELLOW}Загрузка и установка Decky Loader...${NC}"
    rm -f /tmp/user_install_script.sh
    curl -S -s -L -O --output-dir /tmp/ --connect-timeout 60 https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/user_install_script.sh
    bash /tmp/user_install_script.sh
    rm -f /tmp/user_install_script.sh
    check_packages
    read -p "Нажмите Enter..."
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
    read -p "Нажмите Enter..."
}

show_progress() {
    local percent=$1
    local msg=$2
    
    local width=50
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Генерируем строку заполненной части (█)
    local filled_bar=""
    for ((i=0; i<filled; i++)); do
        filled_bar+="█"
    done
    
    # Генерируем строку пустой части (░)
    local empty_bar=""
    for ((i=0; i<empty; i++)); do
        empty_bar+="░"
    done
    
    local bar="${filled_bar}${empty_bar}"
    
    # Перемещаем курсор в начало строки и очищаем до конца строки
    printf "\r\033[2K[%s] %3d%% %s" "$bar" "$percent" "$msg"
}

install_lossless_scaling() {
    check_packages
    if [ "$decky_loader_installed" = false ]; then
        echo -e "${RED}Требуется Decky Loader!${NC}"
        read -p "Нажмите Enter..."
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
    read -p "Нажмите Enter..."
}

install_amnesia_plugin() {
    check_packages
    if [ "$decky_loader_installed" = false ]; then
        echo -e "${RED}Требуется Decky Loader!${NC}"
        read -p "Нажмите Enter..."
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
    read -p "Нажмите Enter..."
}

force_update_packages() {
    # Сначала запрашиваем пароль sudo, БЕЗ прогресс-бара
    echo -e "${YELLOW}Введите пароль sudo для выполнения обновлений...${NC}"
    if ! sudo -v; then
        echo -e "${RED}Ошибка аутентификации sudo.${NC}"
        read -p "Нажмите Enter..."
        return
    fi
    echo ""

    # После пароля показываем прогресс-бар
    show_progress 5 "Очистка кэша download..."

    # Шаг 1: Удаление папок download-* из кэша pacman
    sudo rm -rf /var/cache/pacman/pkg/download-*
    show_progress 15 "Очистка pacman -Sc..."

    # Шаг 2: sudo pacman -Sc --noconfirm
    sudo pacman -Sc --noconfirm > /dev/null 2>&1
    show_progress 35 "Очистка yay -Sc..."

    # Шаг 3: yay -Sc --noconfirm
    yay -Sc --noconfirm > /dev/null 2>&1
    show_progress 55 "Обновление зеркал..."

    # Шаг 4: cachyos-rate-mirrors
    cachyos-rate-mirrors > /dev/null 2>&1
    show_progress 75 "Обновление системы..."

    # Шаг 5: sudo pacman -Syu --noconfirm
    sudo pacman -Syu --noconfirm > /dev/null 2>&1
    show_progress 100 "✅ Обновление завершено"
    echo ""
    read -p "Нажмите Enter..."
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

        # Строим список
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

        # Отображение
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

        read -n1 -s key

        case "$key" in
            $'\x1b')
                read -n2 -s rest
                if [ "$rest" = "[A" ]; then
                    if [ $SELECTED_INDEX -gt 0 ]; then SELECTED_INDEX=$((SELECTED_INDEX - 1)); fi
                elif [ "$rest" = "[B" ]; then
                    if [ $SELECTED_INDEX -lt $((total - 1)) ]; then SELECTED_INDEX=$((SELECTED_INDEX + 1)); fi
                fi
                ;;
            "")
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
                            replace_paru_with_yay; check_packages
                        fi
                    elif [ $cat_num -eq 0 ] && [ $item_num -eq 1 ]; then
                        if [ "$cachyos_gaming_installed" = false ] || [ "$protonup_qt_installed" = false ] || [ "$qbittorrent_installed" = false ] || [ "$portproton_installed" = false ]; then
                            install_gaming_packages; check_packages
                        fi
                    elif [ $cat_num -eq 0 ] && [ $item_num -eq 2 ]; then
                        force_update_packages; check_packages
                    elif [ $cat_num -eq 1 ] && [ $item_num -eq 0 ]; then
                        install_update_koda; check_packages
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 0 ]; then
                        install_decky_loader; check_packages
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 1 ]; then
                        if [ "$decky_loader_installed" = true ]; then install_lossless_scaling; check_packages; fi
                    elif [ $cat_num -eq 2 ] && [ $item_num -eq 2 ]; then
                        if [ "$decky_loader_installed" = true ]; then install_amnesia_plugin; check_packages; fi
                    fi
                fi
                ;;
            q|Q) clear; exit 0 ;;
        esac
    done
}

check_packages
show_menu
