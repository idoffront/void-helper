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

tui() {
   while true; do
        clear

        choice=$(gum choose \
            "Системная информация" \
            "Обновление системы" \
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

        ;;

    update-vh)
        update-vh
        ;;

    find)
        find "$2"
        ;;

    help)
        echo "Доступные команды: vh {*|info|find|update|update-vh||help}"
        echo -e "\e[1m~~~\e[0m"
        echo "vh - открывает минималистичный интерфейс"
        echo "info - выдает достаточно useful информацию об системе"
        echo "find - находит пакет в репозиториях"
        echo "update - обновляет систему/пакеты"
        echo "update-vh - обновляет этот скрипт"
        echo "help - показывает справку"
        ;;


    *)
        tui
        ;;

esac
