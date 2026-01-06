#!/bin/bash

# Скрипт для тестирования вашего webhook

WEBHOOK_URL="http://localhost:5678/webhook/test-webhook"

echo "🧪 Отправляю POST запрос к webhook..."
echo "📍 URL: ${WEBHOOK_URL}"
echo ""

# Данные для отправки
DATA='{
  "test": true,
  "name": "Тестовое сообщение",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "data": {
    "id": 123,
    "message": "Привет из тестового скрипта!",
    "values": [1, 2, 3, 4, 5]
  }
}'

echo "📤 Отправляемые данные:"
echo "$DATA" | jq '.' 2>/dev/null || echo "$DATA"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Отправка запроса
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "${WEBHOOK_URL}" \
  -H "Content-Type: application/json" \
  -H "User-Agent: test-webhook-script/1.0" \
  -d "$DATA")

# Разделяем response body и status code (совместимо с macOS)
HTTP_STATUS=$(echo "$RESPONSE" | tail -n 1)
HTTP_BODY=$(echo "$RESPONSE" | sed '$d')

echo "📥 Ответ от webhook (HTTP ${HTTP_STATUS}):"
echo "$HTTP_BODY" | jq '.' 2>/dev/null || echo "$HTTP_BODY"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Проверка статуса
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Webhook работает отлично!"
    exit 0
elif [ "$HTTP_STATUS" -eq 404 ]; then
    echo "❌ Webhook не найден (404)"
    echo ""
    echo "Проверьте:"
    echo "  1. Workflow импортирован в n8n?"
    echo "  2. Workflow активирован? (переключатель 'Active')"
    echo "  3. Правильный URL? Проверьте в узле Webhook"
    echo ""
    exit 1
else
    echo "⚠️  Неожиданный статус: ${HTTP_STATUS}"
    exit 1
fi

