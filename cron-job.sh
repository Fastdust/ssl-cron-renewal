#!/bin/bash

# Минимальный скрипт обновления SSL сертификатов
# Автор: Fastdust
# Использование: 0 3 1 */3 * /opt/scripts/cron-job.sh
# Требования: certbot, nginx

set -e

# Конфигурация
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
LOG_FILE="/var/log/ssl-renewal.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Простое логирование
log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

# Начало работы
log "Запуск процесса обновления SSL сертификатов"

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    log "ОШИБКА: Скрипт должен запускаться от имени root"
    exit 1
fi

# Временное открытие порта 80, если ufw активен
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    log "Временное открытие порта 80"
    ufw allow 80/tcp > /dev/null || log "Предупреждение: Не удалось открыть порт 80"
fi

# Обновление сертификатов
if certbot renew --nginx --quiet --no-self-upgrade; then
    log "Обновление сертификатов завершено успешно"
    systemctl reload nginx
    log "nginx перезагружен"
    
    # Закрытие порта 80, если мы его открывали
    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        log "Закрытие порта 80"
        ufw delete allow 80/tcp > /dev/null || log "Предупреждение: Не удалось закрыть порт 80"
    fi
else
    log "ОШИБКА: Обновление сертификатов завершилось неудачей"
    # Закрытие порта 80 даже при ошибке
    if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
        ufw delete allow 80/tcp > /dev/null 2>&1
    fi
    exit 1
fi

log "Процесс обновления SSL сертификатов завершен"
