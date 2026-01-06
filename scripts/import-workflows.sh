#!/bin/bash

# Скрипт для импорта workflow в n8n

set -e

BACKUP_DIR="./backups"

if [ -z "$1" ]; then
    echo "📋 Доступные резервные копии:"
    ls -1t "${BACKUP_DIR}"/workflows-*.json 2>/dev/null | nl || echo "Нет резервных копий"
    echo ""
    echo "Использование: $0 <имя-файла>"
    echo "Пример: $0 workflows-20240106_120000.json"
    echo ""
    echo "Или используйте 'latest' для последней копии:"
    echo "Пример: $0 latest"
    exit 1
fi

if [ "$1" == "latest" ]; then
    BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/workflows-*.json 2>/dev/null | head -1)
    if [ -z "$BACKUP_FILE" ]; then
        echo "❌ Нет доступных резервных копий"
        exit 1
    fi
    BACKUP_FILE=$(basename "$BACKUP_FILE")
else
    BACKUP_FILE="$1"
fi

if [ ! -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
    echo "❌ Файл не найден: ${BACKUP_DIR}/${BACKUP_FILE}"
    exit 1
fi

echo "📥 Импортирую workflow из: ${BACKUP_FILE}"

docker exec n8n-ai n8n import:workflow --input="/backups/${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "✅ Workflow успешно импортированы!"
else
    echo "❌ Ошибка при импорте workflow"
    exit 1
fi

