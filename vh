#!/bin/bash

info() {
    echo -e "\e[1mИнформация о Системе\e[0m"
    echo "--------------------"

    distro=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '""')

    kernel=$(uname -r)

    packages=$(xbps-query -l | wc -l)

    de=${XDG_CURRENT_DESKTOP:-Unknown}

    disk=$(df -h / | awk 'NR==2 {print $1 " " $2 " / " $3}')

    uptime=$(uptime -p)

    printf "Дистрибутив  : %s\n" "$distro"
    printf "Ядро         : %s\n" "$kernel"
    printf "Пакеты       : %s\n" "$packages"
    printf "Граф. Окруж. : %s\n" "$de"
    printf "Диск         : %s\n" "$disk"
    printf "Время работы : %s\n" "$uptime"
    echo
    echo "Репозитории:"

    xbps-query -L | sed 's/^/ [*] /'
}

update() {
    sudo -v
    echo -e "\e[1mСинхронизация репозиториев\e[0m"
    echo
    sudo xbps-install -S
    echo
    echo -e "\e[1mОбновление пакетов\e[0m"
    echo
    sudo xbps-install -u
    echo
    echo -e "\e[1mПакеты обновлены или обновлений нет\e[0m"
    echo
    sudo xbps-remove -o
    echo
    echo -e "\e[1mГотово!\e[0m"
}

update-vh() {
    echo -e "\e[1mОбновление Void-Helper\e[0m"
    curl -fsSL https://raw.githubusercontent.com/idoffront/void-helper/main/install | bash
    echo -e "\e[1mОбновление завершено.\e[0m"
}

find() {
    packet=$1
    query=$(xbps-query -Rs "$packet" 2>/dev/null)

    echo -e "\e[1mПоиск пакета:\e[0m"
    if echo "$query" | grep -q  '[-]'; then
        xbps-query -Rs "$packet"
    else
        echo -e "\e[1mПакет не найден.\e[0m"
        echo -e "\e[1mПопробуйте написать название с большой, либо маленькой буквы.\e[0m"
    fi
}

# Пресеты. Спасибо господи что дал такую вещь как Zed, я даже не напрягался.

preset() {
    echo -e "\e[1mВыберите пресет:\e[0m"
    choice=$(gum choose \
        "KDE Plasma" \
        "GNOME" \
        "Xfce" \
        "Niri" \
        "Добавить набор программ")

        if gum confirm "Вы уверены, что хотите выбрать $choice?"; then
            case "$choice" in
                "KDE Plasma")
                    preset_kde
                    ;;
                "GNOME")
                    preset_gnome
                    ;;
                "Xfce")
                    preset_xfce
                    ;;
                "Niri")
                    preset_niri
                    ;;
                "Добавить набор программ")
                    preset_add_packages
                    ;;
            esac
        fi
}

# Пресеты десктоп энвайронмент так называемых

preset_kde() {
    echo -e "\e[1mВы выбрали KDE Plasma\e[0m"
    echo "Будут установлены:"
    echo "KDE Plasma"
    echo "SDDM"

    if gum confirm "Установить KDE Plasma?"; then
        echo "Устанавливаю KDE Plasma..."
        sudo xbps-install -S kde-plasma sddm
        sudo ln -s /etc/sv/sddm /var/service
        echo "Установка завершена. SDDM добавлен в автозагрузку. Можете выбрать дополнительные пакеты в "Добавить пакеты"."
    fi
}

preset_gnome() {
    echo -e "\e[1mВы выбрали GNOME\e[0m"
    echo "Будут установлены:"
    echo "GNOME"
    echo "GDM"

    if gum confirm "Установить GNOME?"; then
        echo "Устанавливаю GNOME..."
        sudo xbps-install -S gnome gdm
        sudo ln -s /etc/sv/gdm /var/service
        echo "Установка завершена. GDM добавлен в автозагрузку. Можете выбрать дополнительные пакеты в "Добавить пакеты"."
    fi
}

preset_xfce() {
    echo -e "\e[1mВы выбрали XFCE\e[0m"
    echo "Будут установлены:"
    echo "XFCE"
    echo "lightdm"

    if gum confirm "Установить XFCE?"; then
        echo "Устанавливаю XFCE..."
        sudo xbps-install -S xfce4 lightdm
        sudo ln -s /etc/sv/lightdm /var/service
        echo "Установка завершена. LightDM добавлен в автозагрузку. Можете выбрать дополнительные пакеты в "Добавить пакеты"."
    fi
}

preset_niri() {
    echo -e "\e[1mВы выбрали Niri\e[0m"
    echo "Будут установлены:"
    echo "Niri"
    echo "sddm"

    if gum confirm "Установить Niri?"; then
        echo "Устанавливаю Niri..."
        sudo xbps-install -S niri sddm
        sudo ln -s /etc/sv/sddm /var/service
        echo "Установка завершена. SDDM добавлен в автозагрузку. Можете выбрать дополнительные пакеты в "Добавить пакеты"."
    fi
}

# Добавление пакетов (кому это нужно лол)

preset_add_packages() {
    packages=$(gum choose \
        "KDE Apps" \
        "Noctalia" \
        "Office" \
        "Multimedia" \
        "Internet")

    case "$packages" in
        "KDE Apps")
            preset_kde_apps
            ;;
        "Noctalia")
            preset_noctalia
            ;;
        "Office")
            preset_office
            ;;
        "Multimedia")
            preset_multimedia
            ;;
        "Internet")
            preset_internet
            ;;
    esac
}

# Пресеты приложений

preset_kde_apps() {
    echo -e "\e[1mУстановка KDE Apps:\e[0m"
    sudo xbps-install -S kde-applications
    echo -e "\e[1mУстановка завершена.\e[0m"
}

preset_noctalia() {
    echo -e "\e[1mУстановка Noctalia:\e[0m"
    echo "repository=https://repo.voiders.dev" | sudo tee /etc/xbps.d/10-voiders-community.conf
    sudo xbps-install -S noctalia
    echo -e "\e[1mУстановка завершена. Добавьте Noctalia в конфиг вашего окружения.\e[0m"
}

preset_office() {
    echo -e "\e[1mУстановка Office:\e[0m"
    sudo xbps-install -S libreoffice
    echo -e "\e[1mУстановка завершена.\e[0m"
}

preset_multimedia() {
    echo -e "\e[1mУстановка Multimedia:\e[0m"
    sudo xbps-install -S vlc mpv
    echo -e "\e[1mУстановка завершена.\e[0m"
}

preset_internet() {
    echo -e "\e[1mУстановка Internet:\e[0m"
    sudo xbps-install -S firefox thunderbird
    echo -e "\e[1mУстановка завершена.\e[0m"
}

# Пресеты приложений кончились

tui() {
   while true; do
        clear

        choice=$(gum choose \
            "Системная информация" \
            "Обновление системы" \
            "Установка Desktop Environment" \
            "Проверка сервисов" \
            "Поиск пакета" \
            "Обновление скрипта" \
            "Выход")

        clear

        case "$choice" in
            "Системная информация")
                clear
                info
                ;;

            "Обновление системы")
                clear
                update
                ;;

            "Установка Desktop Environment")
                clear
                preset
                ;;

            "Поиск пакета")
                read -p "Пакет:" package
                find "$package"
                ;;

            "Обновление скрипта")
                update-vh
                ;;

            "Выход")
                break
                ;;
        esac

        echo
        read -p "Нажмите Enter чтобы вернуться в меню"
        clear
    done
}

case "$1" in
    info)
        info
        ;;

    update)
        update
        ;;

    preset)
        preset
        ;;

    update-vh)
        update-vh
        ;;

    find)
        find "$2"
        ;;

    help)
        echo "Доступные команды: vh {*|info|find|update|update-vh|preset|help}"
        echo -e "\e[1m~~~\e[0m"
        echo "vh - открывает минималистичный интерфейс"
        echo "info - выдает достаточно useful информацию об системе"
        echo "find - находит пакет в репозиториях"
        echo "update - обновляет систему/пакеты"
        echo "update-vh - обновляет этот скрипт"
        echo "preset - устанавливает Desktop Environment"
        echo "help - показывает справку"
        ;;


    *)
        tui
        ;;

esac
