#!/bin/bash

# Скрипт для экспорта всех workflow из n8n

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="workflows-${TIMESTAMP}.json"

echo "🔄 Экспортирую workflow из n8n..."

# Создаем директорию для бэкапов если её нет
mkdir -p "$BACKUP_DIR"

# Экспортируем workflow
docker exec n8n-prototype n8n export:workflow --all --output="/backups/${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "✅ Workflow успешно экспортированы в: ${BACKUP_DIR}/${BACKUP_FILE}"
    
    # Показываем размер файла
    if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
        SIZE=$(ls -lh "${BACKUP_DIR}/${BACKUP_FILE}" | awk '{print $5}')
        echo "📦 Размер файла: ${SIZE}"
    fi
    
    # Удаляем старые бэкапы (оставляем последние 10)
    echo "🧹 Очищаю старые бэкапы..."
    ls -t "${BACKUP_DIR}"/workflows-*.json | tail -n +11 | xargs -r rm
    
    echo "✨ Готово!"
else
    echo "❌ Ошибка при экспорте workflow"
    exit 1
fi

