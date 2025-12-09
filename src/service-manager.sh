#!/bin/bash

# ===========================================
# КОНФИГУРАЦИЯ
# ===========================================
REQUIRED_USER="user-12-47"
LOG_FILE="$HOME/service-manager.log"
CURRENT_USER=$(whoami)

# ЦВЕТА ДЛЯ ВЫВОДА
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ===========================================
# ПРОВЕРКА ПОЛЬЗОВАТЕЛЯ
# ===========================================
if [ "$CURRENT_USER" != "$REQUIRED_USER" ]; then
    echo -e "${RED}ОШИБКА ДОСТУПА!${NC}"
    echo "Эта утилита должна запускаться под пользователем: $REQUIRED_USER"
    echo "Текущий пользователь: $CURRENT_USER"
    echo ""
    echo "Для переключения выполните:"
    echo "  su - user-12-47"
    echo "  пароль: student123"
    exit 1
fi

# ===========================================
# ФУНКЦИИ
# ===========================================
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

show_services() {
    echo -e "${BLUE}=== ВАШИ СЕРВИСЫ ===${NC}"
    systemctl --user list-units --type=service --all --no-pager
    log_action "Просмотр списка сервисов"
}

check_status() {
    read -p "Введите имя сервиса: " service
    echo ""
    echo -e "${YELLOW}Статус сервиса '$service':${NC}"
    systemctl --user status "$service" --no-pager
    log_action "Проверка статуса сервиса: $service"
}

start_service() {
    read -p "Введите имя сервиса: " service
    echo ""
    echo -e "${GREEN}Запуск сервиса '$service'...${NC}"
    
    if systemctl --user start "$service" 2>/dev/null; then
        echo -e "${GREEN}✓ Сервис успешно запущен${NC}"
        log_action "Запуск сервиса: $service"
    else
        echo -e "${RED}✗ Ошибка запуска сервиса${NC}"
        log_action "Ошибка запуска сервиса: $service"
    fi
}

stop_service() {
    read -p "Введите имя сервиса: " service
    echo ""
    echo -e "${YELLOW}Остановка сервиса '$service'...${NC}"
    
    if systemctl --user stop "$service" 2>/dev/null; then
        echo -e "${YELLOW}✓ Сервис успешно остановлен${NC}"
        log_action "Остановка сервиса: $service"
    else
        echo -e "${RED}✗ Ошибка остановки сервиса${NC}"
        log_action "Ошибка остановки сервиса: $service"
    fi
}

restart_service() {
    read -p "Введите имя сервиса: " service
    echo ""
    echo -e "${BLUE}Перезапуск сервиса '$service'...${NC}"
    
    if systemctl --user restart "$service" 2>/dev/null; then
        echo -e "${BLUE}✓ Сервис успешно перезапущен${NC}"
        log_action "Перезапуск сервиса: $service"
    else
        echo -e "${RED}✗ Ошибка перезапуска сервиса${NC}"
        log_action "Ошибка перезапуска сервиса: $service"
    fi
}

show_logs() {
    echo -e "${BLUE}=== ЖУРНАЛ ДЕЙСТВИЙ ===${NC}"
    if [ -f "$LOG_FILE" ]; then
        if [ -s "$LOG_FILE" ]; then
            tail -20 "$LOG_FILE"
        else
            echo "Журнал пуст."
        fi
    else
        echo "Файл журнала не найден."
    fi
}

create_test_service() {
    echo "Создание тестового сервиса..."
    
    mkdir -p ~/.config/systemd/user/
    
    cat > ~/.config/systemd/user/test-custom.service << 'SERVICE'
[Unit]
Description=Тестовый сервис

[Service]
Type=simple
ExecStart=/bin/bash -c 'echo "Сервис работает: $(date)" >> /tmp/test.log && sleep 3600'
Restart=on-failure

[Install]
WantedBy=default.target
SERVICE
    
    systemctl --user daemon-reload
    echo -e "${GREEN}✓ Тестовый сервис создан${NC}"
    echo "Имя: test-custom"
    log_action "Создан тестовый сервис: test-custom"
}

# ===========================================
# МЕНЮ
# ===========================================
show_menu() {
    clear
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}  УТИЛИТА ДЛЯ МОНИТОРИНГА И УПРАВЛЕНИЯ  ${NC}"
    echo -e "${GREEN}  СИСТЕМНЫМИ СЕРВИСАМИ ПОЛЬЗОВАТЕЛЯ    ${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "Разработчик: Смирнов М.Д., группа КТСО-12-24"
    echo "Пользователь: $CURRENT_USER"
    echo "Дата: $(date '+%d.%m.%Y %H:%M:%S')"
    echo ""
    echo "1. Показать все сервисы"
    echo "2. Проверить статус сервиса"
    echo "3. Запустить сервис"
    echo "4. Остановить сервис"
    echo "5. Перезапустить сервис"
    echo "6. Показать журнал действий"
    echo "7. Создать тестовый сервис"
    echo "0. Выход"
    echo ""
    echo -e "${GREEN}=========================================${NC}"
}

# ===========================================
# ОСНОВНАЯ ПРОГРАММА
# ===========================================
main() {
    log_action "Запуск утилиты. Пользователь: $CURRENT_USER"
    
    echo -e "${GREEN}Утилита мониторинга сервисов запущена${NC}"
    echo -e "Логи: $LOG_FILE"
    echo ""
    read -p "Нажмите Enter для продолжения..."
    
    while true; do
        show_menu
        read -p "Выберите действие [0-7]: " choice
        
        case $choice in
            1) show_services ;;
            2) check_status ;;
            3) start_service ;;
            4) stop_service ;;
            5) restart_service ;;
            6) show_logs ;;
            7) create_test_service ;;
            0)
                echo "Выход..."
                log_action "Завершение работы утилиты"
                exit 0
                ;;
            *)
                echo -e "${RED}Неверный выбор!${NC}"
                ;;
        esac
        
        echo ""
        read -p "Нажмите Enter для продолжения..."
    done
}

# ЗАПУСК
main
