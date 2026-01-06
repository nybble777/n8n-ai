#!/bin/bash

# Скрипт для проверки доступности webhook

echo "🔍 Проверка webhook..."
echo ""

# Проверка n8n
echo "1️⃣  Проверяю запущен ли n8n..."
if docker ps | grep -q n8n-prototype; then
    echo "   ✅ n8n запущен"
else
    echo "   ❌ n8n не запущен"
    echo "   Запустите: make start"
    exit 1
fi
echo ""

# Проверка доступности n8n
echo "2️⃣  Проверяю доступность n8n..."
if curl -s http://localhost:5678 > /dev/null; then
    echo "   ✅ n8n доступен на http://localhost:5678"
else
    echo "   ❌ n8n недоступен"
    exit 1
fi
echo ""

# Проверка Test URL
echo "3️⃣  Проверяю Test webhook URL..."
TEST_URL="http://localhost:5678/webhook-test/test-webhook"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$TEST_URL" \
  -H "Content-Type: application/json" \
  -d '{"test":true}')

if [ "$STATUS" = "200" ]; then
    echo "   ✅ Test webhook работает (HTTP 200)"
    echo "   URL: $TEST_URL"
elif [ "$STATUS" = "404" ]; then
    echo "   ⚠️  Test webhook не найден (HTTP 404)"
    echo ""
    echo "   НЕОБХОДИМЫЕ ДЕЙСТВИЯ:"
    echo "   1. Откройте: http://localhost:5678"
    echo "   2. Импортируйте: examples/example-workflow-webhook.json"
    echo "      (Menu ☰ → Import from File)"
    echo "   3. Активируйте workflow (переключатель 'Active')"
    echo ""
    echo "   📖 Подробная инструкция: IMPORT_GUIDE.md"
else
    echo "   ⚠️  Неожиданный статус: HTTP $STATUS"
fi
echo ""

# Проверка Production URL
echo "4️⃣  Проверяю Production webhook URL..."
PROD_URL="http://localhost:5678/webhook/test-webhook"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$PROD_URL" \
  -H "Content-Type: application/json" \
  -d '{"test":true}')

if [ "$STATUS" = "200" ]; then
    echo "   ✅ Production webhook работает (HTTP 200)"
    echo "   URL: $PROD_URL"
elif [ "$STATUS" = "404" ]; then
    echo "   ⚠️  Production webhook не найден (HTTP 404)"
    echo "   Это нормально, если workflow не активирован"
else
    echo "   ⚠️  Неожиданный статус: HTTP $STATUS"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 РЕЗЮМЕ:"
echo ""
echo "Для работы webhook нужно:"
echo "  1. ✅ n8n запущен - проверьте: docker ps"
echo "  2. 📥 Workflow импортирован - проверьте в веб-интерфейсе"
echo "  3. ⚡ Workflow активирован - включите 'Active'"
echo ""
echo "После этого используйте:"
echo "  ./test-my-webhook.sh"
echo ""
echo "📖 Инструкция: IMPORT_GUIDE.md"
echo "🌐 Веб-интерфейс: http://localhost:5678"
echo ""

