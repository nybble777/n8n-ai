#!/bin/bash

# Скрипт для тестирования webhook в n8n

WEBHOOK_PATH="${1:-test-webhook}"
N8N_URL="${N8N_URL:-http://localhost:5678}"

echo "🧪 Тестирую webhook: ${N8N_URL}/webhook/${WEBHOOK_PATH}"
echo ""

# Пример данных для отправки
DATA='{
  "test": true,
  "message": "Hello from test script",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "data": {
    "id": 123,
    "name": "Test Item",
    "values": [1, 2, 3, 4, 5]
  }
}'

echo "📤 Отправляю данные:"
echo "$DATA" | jq '.' 2>/dev/null || echo "$DATA"
echo ""

# Отправка запроса
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${N8N_URL}/webhook-test/${WEBHOOK_PATH}" \
  -H "Content-Type: application/json" \
  -H "User-Agent: n8n-test-script/1.0" \
  -d "$DATA")

# Разделяем response body и status code (совместимо с macOS)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')

echo "📥 Ответ (HTTP ${HTTP_STATUS}):"
echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"
echo ""

# Проверка статуса
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Webhook работает корректно!"
    exit 0
elif [ "$HTTP_STATUS" -eq 404 ]; then
    echo "❌ Webhook не найден. Проверьте:"
    echo "   1. Workflow активирован?"
    echo "   2. Правильный путь? Используйте: $0 <webhook-path>"
    exit 1
else
    echo "⚠️  Получен неожиданный статус: ${HTTP_STATUS}"
    exit 1
fi

