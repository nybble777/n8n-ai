#!/bin/bash

# Скрипт для запуска n8n с публичным доступом

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         🌍 Публикация n8n для доступа из интернета          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Проверка безопасности
echo "🔐 Проверяю настройки безопасности..."

if grep -q "N8N_BASIC_AUTH_ACTIVE=false" docker-compose.yml || ! grep -q "N8N_BASIC_AUTH_ACTIVE=true" docker-compose.yml; then
    echo ""
    echo "⚠️  ВНИМАНИЕ! Базовая аутентификация не включена!"
    echo ""
    echo "Перед публикацией в интернет ОБЯЗАТЕЛЬНО включите защиту:"
    echo ""
    echo "1. Отредактируйте docker-compose.yml"
    echo "2. Измените строки:"
    echo "   N8N_BASIC_AUTH_ACTIVE=false  →  N8N_BASIC_AUTH_ACTIVE=true"
    echo "   # Раскомментируйте:"
    echo "   N8N_BASIC_AUTH_USER=admin"
    echo "   N8N_BASIC_AUTH_PASSWORD=ваш_надежный_пароль"
    echo ""
    read -p "Продолжить БЕЗ защиты? (только для локальных тестов) [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Отменено. Включите аутентификацию и запустите снова."
        exit 1
    fi
    echo "⚠️  Продолжаем БЕЗ аутентификации (небезопасно!)"
else
    echo "✅ Базовая аутентификация включена"
fi

echo ""

# Проверка что n8n запущен
if ! docker ps | grep -q n8n-prototype; then
    echo "🚀 Запускаю n8n..."
    make start
    echo "⏳ Ждем полный запуск n8n (10 секунд)..."
    sleep 10
else
    echo "✅ n8n уже запущен"
fi

echo ""
echo "🌍 Выберите способ публикации:"
echo ""
echo "1) ngrok         - Рекомендуется (требует регистрации)"
echo "2) localtunnel   - Быстро (без регистрации)"
echo "3) cloudflared   - Постоянный URL (требует настройки)"
echo "4) Отмена"
echo ""

read -p "Ваш выбор (1-4): " choice
echo ""

case $choice in
    1)
        echo "📡 Запуск ngrok..."
        echo ""
        
        # Проверка установки ngrok
        if ! command -v ngrok &> /dev/null; then
            echo "❌ ngrok не установлен"
            echo ""
            echo "Установите с помощью:"
            echo "  brew install ngrok"
            echo ""
            echo "Затем:"
            echo "  1. Зарегистрируйтесь: https://dashboard.ngrok.com/signup"
            echo "  2. Получите authtoken: https://dashboard.ngrok.com/get-started/your-authtoken"
            echo "  3. Настройте: ngrok authtoken YOUR_TOKEN"
            echo ""
            exit 1
        fi
        
        # Проверка авторизации
        if ! ngrok config check &> /dev/null; then
            echo "⚠️  ngrok не настроен"
            echo ""
            echo "Получите токен: https://dashboard.ngrok.com/get-started/your-authtoken"
            echo "И выполните: ngrok authtoken YOUR_TOKEN"
            echo ""
            exit 1
        fi
        
        echo "✅ ngrok готов к запуску"
        echo ""
        echo "n8n будет доступен по URL который покажет ngrok"
        echo "Нажмите Ctrl+C для остановки"
        echo ""
        
        ngrok http 5678
        ;;
        
    2)
        echo "📡 Запуск localtunnel..."
        echo ""
        
        # Проверка установки localtunnel
        if ! command -v lt &> /dev/null; then
            echo "⚠️  localtunnel не установлен"
            echo ""
            echo "Устанавливаю..."
            npm install -g localtunnel
            echo ""
        fi
        
        echo "Выберите поддомен (или Enter для случайного):"
        read -p "Поддомен: " subdomain
        echo ""
        
        if [ -z "$subdomain" ]; then
            echo "Запуск со случайным поддоменом..."
            lt --port 5678
        else
            echo "Запуск с поддоменом: ${subdomain}.loca.lt"
            lt --port 5678 --subdomain "$subdomain"
        fi
        ;;
        
    3)
        echo "📡 Запуск Cloudflare Tunnel..."
        echo ""
        
        if ! command -v cloudflared &> /dev/null; then
            echo "❌ cloudflared не установлен"
            echo ""
            echo "Установите с помощью:"
            echo "  brew install cloudflare/cloudflare/cloudflared"
            echo ""
            echo "Затем настройте туннель:"
            echo "  1. cloudflared tunnel login"
            echo "  2. cloudflared tunnel create n8n-prototype"
            echo "  3. Настройте config.yml"
            echo ""
            echo "📖 Подробная инструкция: PUBLIC_ACCESS_GUIDE.md"
            exit 1
        fi
        
        echo "Запуск Quick Tunnel (временный URL)..."
        echo "Для постоянного URL настройте туннель (см. PUBLIC_ACCESS_GUIDE.md)"
        echo ""
        
        cloudflared tunnel --url http://localhost:5678
        ;;
        
    4)
        echo "❌ Отменено"
        exit 0
        ;;
        
    *)
        echo "❌ Неверный выбор"
        exit 1
        ;;
esac

