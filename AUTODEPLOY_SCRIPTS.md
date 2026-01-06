# 📦 Готовые скрипты для автодеплоя

Все необходимые скрипты и конфиги для быстрой настройки автодеплоя.

---

## 🚀 Метод 1: GitHub Actions (РЕКОМЕНДУЮ)

### Шаг 1: Настройте сервер

Выполните на вашем сервере:

```bash
#!/bin/bash
# setup-server.sh - Настройка сервера для автодеплоя

set -e

echo "🔧 Настройка сервера для автодеплоя n8n..."

# 1. Создание SSH ключа для GitHub Actions
echo "📝 Создание SSH ключа..."
ssh-keygen -t ed25519 -C "github-deploy" -f ~/.ssh/github_deploy -N ""
cat ~/.ssh/github_deploy.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

echo ""
echo "📋 СКОПИРУЙТЕ ЭТОТ ПРИВАТНЫЙ КЛЮЧ в GitHub Secrets (SSH_PRIVATE_KEY):"
echo "=========================================="
cat ~/.ssh/github_deploy
echo "=========================================="

# 2. Создание директории для n8n
echo ""
echo "📁 Создание директории для n8n..."
sudo mkdir -p /opt/n8n
sudo chown $USER:$USER /opt/n8n
cd /opt/n8n

# 3. Клонирование репозитория
echo ""
read -p "📥 Введите URL репозитория (например: https://github.com/nybble777/n8n-ai.git): " REPO_URL
git clone $REPO_URL .

# 4. Создание .env файла
echo ""
echo "🔐 Создание .env файла..."

read -p "Введите домен (например: n8n.example.com): " DOMAIN
read -s -p "Введите пароль для n8n: " N8N_PASSWORD
echo ""
read -s -p "Введите encryption key (или оставьте пустым для генерации): " ENCRYPTION_KEY
echo ""

if [ -z "$ENCRYPTION_KEY" ]; then
  ENCRYPTION_KEY=$(openssl rand -base64 32)
  echo "✅ Encryption key сгенерирован"
fi

POSTGRES_PASSWORD=$(openssl rand -base64 20)

cat > .env << EOF
# n8n Configuration
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_HOST=$DOMAIN
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD
N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
WEBHOOK_URL=https://$DOMAIN

# Database Configuration
DB_TYPE=postgresdb
POSTGRES_USER=n8n
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=n8n
DATABASE_URL=postgres://n8n:$POSTGRES_PASSWORD@postgres:5432/n8n

# Timezone
GENERIC_TIMEZONE=Europe/Moscow
TZ=Europe/Moscow

# Node Environment
NODE_ENV=production
EOF

echo "✅ .env файл создан"

# 5. Установка Docker (если не установлен)
if ! command -v docker &> /dev/null; then
    echo ""
    echo "🐳 Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker установлен"
else
    echo "✅ Docker уже установлен"
fi

# 6. Первый запуск
echo ""
echo "🚀 Запуск n8n..."
docker compose -f docker-compose.production.yml up -d

echo ""
echo "=========================================="
echo "✅ Настройка сервера завершена!"
echo "=========================================="
echo ""
echo "📋 Добавьте эти секреты в GitHub:"
echo "  SSH_HOST: $(curl -s ifconfig.me)"
echo "  SSH_USER: $USER"
echo "  SSH_PORT: 22"
echo "  SSH_PRIVATE_KEY: (скопируйте приватный ключ выше)"
echo ""
echo "📖 Инструкция: AUTODEPLOY_OWN_SERVER.md"
echo ""
echo "🌐 n8n будет доступен на: https://$DOMAIN"
echo "👤 Логин: admin"
echo "🔑 Пароль: $N8N_PASSWORD"
echo ""
echo "⚠️  Не забудьте настроить SSL (Let's Encrypt)!"
echo ""
```

Сохраните как `setup-server.sh` и выполните:

```bash
chmod +x setup-server.sh
./setup-server.sh
```

---

### Шаг 2: Настройте GitHub Secrets

1. Откройте: https://github.com/nybble777/n8n-ai/settings/secrets/actions
2. New repository secret для каждого:

```
Name: SSH_HOST
Value: ваш-ip-адрес (например: 123.45.67.89)

Name: SSH_USER  
Value: ваш-пользователь (например: root или ubuntu)

Name: SSH_PORT
Value: 22

Name: SSH_PRIVATE_KEY
Value: (вставьте приватный ключ из вывода setup-server.sh)
```

---

### Шаг 3: Готово!

Workflow `.github/workflows/deploy.yml` уже создан в проекте!

Теперь при каждом push в main автоматически задеплоится на ваш сервер.

---

## 🎣 Метод 2: Webhook на сервере

### Установка webhook listener

```bash
#!/bin/bash
# install-webhook.sh

set -e

echo "🎣 Установка webhook listener..."

# 1. Установка webhook
sudo npm install -g webhook

# 2. Создание директории
sudo mkdir -p /opt/webhook
cd /opt/webhook

# 3. Генерация секрета
WEBHOOK_SECRET=$(openssl rand -hex 20)

# 4. Создание конфига
sudo cat > hooks.json << EOF
[
  {
    "id": "deploy-n8n",
    "execute-command": "/opt/webhook/deploy.sh",
    "command-working-directory": "/opt/n8n",
    "pass-arguments-to-command": [
      {
        "source": "payload",
        "name": "ref"
      }
    ],
    "trigger-rule": {
      "and": [
        {
          "match": {
            "type": "payload-hash-sha256",
            "secret": "$WEBHOOK_SECRET",
            "parameter": {
              "source": "header",
              "name": "X-Hub-Signature-256"
            }
          }
        },
        {
          "match": {
            "type": "value",
            "value": "refs/heads/main",
            "parameter": {
              "source": "payload",
              "name": "ref"
            }
          }
        }
      ]
    }
  }
]
EOF

# 5. Создание deploy скрипта
sudo cat > deploy.sh << 'EOF'
#!/bin/bash

set -e

LOG_FILE="/var/log/n8n-deploy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "================================================"
log "🚀 Starting deployment"
log "================================================"

cd /opt/n8n

log "📥 Pulling latest changes..."
git fetch origin
git reset --hard origin/main

log "🔨 Rebuilding containers..."
docker compose -f docker-compose.production.yml down
docker compose -f docker-compose.production.yml up -d --build

log "⏳ Waiting for n8n..."
sleep 30

log "✅ Checking health..."
if curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    log "✅ Deployment successful!"
else
    log "❌ Health check failed!"
    exit 1
fi

log "================================================"
log "🎉 Deployment completed"
log "================================================"
EOF

sudo chmod +x deploy.sh

# 6. Создание systemd service
sudo cat > /etc/systemd/system/webhook.service << 'EOF'
[Unit]
Description=Webhook Listener for n8n Deploy
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/webhook
ExecStart=/usr/bin/webhook -hooks /opt/webhook/hooks.json -verbose -port 9000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 7. Запуск service
sudo systemctl daemon-reload
sudo systemctl enable webhook
sudo systemctl start webhook

# 8. Настройка firewall (если используется ufw)
if command -v ufw &> /dev/null; then
    sudo ufw allow 9000/tcp
fi

echo ""
echo "=========================================="
echo "✅ Webhook listener установлен!"
echo "=========================================="
echo ""
echo "📋 Настройте webhook в GitHub:"
echo "  URL: http://$(curl -s ifconfig.me):9000/hooks/deploy-n8n"
echo "  Content type: application/json"
echo "  Secret: $WEBHOOK_SECRET"
echo "  Events: Just the push event"
echo ""
echo "📊 Проверить статус:"
echo "  sudo systemctl status webhook"
echo ""
echo "📝 Логи деплоя:"
echo "  tail -f /var/log/n8n-deploy.log"
echo ""
```

Выполните:

```bash
chmod +x install-webhook.sh
sudo ./install-webhook.sh
```

---

## 🔄 Deploy скрипт (ручной деплой)

Для ручного деплоя с сервера:

```bash
#!/bin/bash
# deploy.sh - Ручной деплой n8n

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "================================================"
echo "🚀 n8n Manual Deployment"
echo "================================================"

# Проверка что мы в правильной директории
if [ ! -f "docker-compose.production.yml" ]; then
    echo "❌ docker-compose.production.yml не найден!"
    exit 1
fi

# Backup текущей версии
echo ""
echo "💾 Creating backup tag..."
BACKUP_TAG="backup-$(date +%Y%m%d-%H%M%S)"
git tag -a "$BACKUP_TAG" -m "Backup before deploy"
echo "✅ Backup tag created: $BACKUP_TAG"

# Pull изменений
echo ""
echo "📥 Pulling latest changes..."
git fetch origin
BEFORE_COMMIT=$(git rev-parse HEAD)
git pull origin main
AFTER_COMMIT=$(git rev-parse HEAD)

if [ "$BEFORE_COMMIT" = "$AFTER_COMMIT" ]; then
    echo "ℹ️  No changes to deploy"
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# Показать изменения
echo ""
echo "📝 Changes:"
git log --oneline $BEFORE_COMMIT...$AFTER_COMMIT

# Подтверждение
echo ""
read -p "Continue with deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

# Остановка контейнеров
echo ""
echo "🛑 Stopping containers..."
docker compose -f docker-compose.production.yml down

# Backup базы данных
echo ""
echo "💾 Backing up database..."
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/n8n-db-$(date +%Y%m%d-%H%M%S).sql"
docker compose -f docker-compose.production.yml run --rm postgres pg_dump -U n8n n8n > $BACKUP_FILE
echo "✅ Database backed up to: $BACKUP_FILE"

# Сборка и запуск
echo ""
echo "🔨 Building and starting containers..."
docker compose -f docker-compose.production.yml build
docker compose -f docker-compose.production.yml up -d

# Ожидание запуска
echo ""
echo "⏳ Waiting for n8n to start..."
sleep 30

# Health check
echo ""
echo "✅ Checking health..."
MAX_RETRIES=10
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
        echo "✅ n8n is healthy!"
        break
    fi
    RETRY=$((RETRY+1))
    echo "⏳ Retry $RETRY/$MAX_RETRIES..."
    sleep 5
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "❌ Health check failed!"
    echo "📝 Showing logs:"
    docker compose -f docker-compose.production.yml logs --tail=100 n8n
    
    echo ""
    read -p "Rollback to previous version? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🔄 Rolling back..."
        git checkout $BACKUP_TAG
        docker compose -f docker-compose.production.yml down
        docker compose -f docker-compose.production.yml up -d --build
    fi
    exit 1
fi

# Показать статус
echo ""
echo "📊 Container status:"
docker compose -f docker-compose.production.yml ps

echo ""
echo "================================================"
echo "🎉 Deployment completed successfully!"
echo "================================================"
echo ""
echo "📝 Commit: $AFTER_COMMIT"
echo "💾 Backup tag: $BACKUP_TAG"
echo "💾 DB backup: $BACKUP_FILE"
echo ""
echo "📊 Logs:"
echo "  docker compose -f docker-compose.production.yml logs -f n8n"
echo ""
```

Сохраните как `deploy.sh` и используйте:

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 🔄 Rollback скрипт

Откат к предыдущей версии:

```bash
#!/bin/bash
# rollback.sh - Откат к предыдущей версии

set -e

cd /opt/n8n

echo "🔄 Rollback n8n"
echo ""

# Показать последние backup tags
echo "📋 Available backups:"
git tag -l "backup-*" | tail -n 10

echo ""
read -p "Enter backup tag to rollback to: " BACKUP_TAG

if [ -z "$BACKUP_TAG" ]; then
    echo "❌ No tag specified"
    exit 1
fi

if ! git rev-parse "$BACKUP_TAG" >/dev/null 2>&1; then
    echo "❌ Tag not found: $BACKUP_TAG"
    exit 1
fi

echo ""
read -p "⚠️  Rollback to $BACKUP_TAG? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo ""
echo "🔄 Rolling back..."
git checkout $BACKUP_TAG

echo "🛑 Stopping containers..."
docker compose -f docker-compose.production.yml down

echo "🔨 Starting previous version..."
docker compose -f docker-compose.production.yml up -d --build

echo "⏳ Waiting..."
sleep 30

echo "✅ Checking health..."
if curl -f http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ Rollback successful!"
else
    echo "❌ Health check failed!"
    docker compose -f docker-compose.production.yml logs --tail=50 n8n
    exit 1
fi

echo ""
echo "🎉 Rolled back to $BACKUP_TAG"
```

---

## 📊 Мониторинг скрипт

Проверка здоровья n8n:

```bash
#!/bin/bash
# monitor.sh - Мониторинг n8n

check_health() {
    if curl -f -s http://localhost:5678/healthz > /dev/null; then
        return 0
    else
        return 1
    fi
}

send_alert() {
    # Отправка уведомления (настройте под себя)
    echo "⚠️  ALERT: n8n is down! $(date)" | tee -a /var/log/n8n-monitor.log
    
    # Пример отправки в Telegram
    # curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    #   -d chat_id="$CHAT_ID" \
    #   -d text="⚠️ n8n is down!"
}

restart_service() {
    echo "🔄 Attempting to restart n8n..." | tee -a /var/log/n8n-monitor.log
    cd /opt/n8n
    docker compose -f docker-compose.production.yml restart n8n
    sleep 30
}

# Основной цикл
while true; do
    if ! check_health; then
        echo "❌ Health check failed at $(date)" | tee -a /var/log/n8n-monitor.log
        send_alert
        restart_service
        
        # Проверяем после перезапуска
        if check_health; then
            echo "✅ Service recovered at $(date)" | tee -a /var/log/n8n-monitor.log
        else
            echo "⚠️  Service still down after restart!" | tee -a /var/log/n8n-monitor.log
        fi
    fi
    
    sleep 60  # Проверка каждую минуту
done
```

Запуск в фоне:

```bash
chmod +x monitor.sh
nohup ./monitor.sh > /dev/null 2>&1 &
```

---

## 🎯 Все скрипты в одном месте

Создайте папку `scripts/` в проекте:

```bash
mkdir -p scripts
cd scripts

# Скачайте все скрипты
curl -O https://raw.githubusercontent.com/nybble777/n8n-ai/main/scripts/setup-server.sh
curl -O https://raw.githubusercontent.com/nybble777/n8n-ai/main/scripts/deploy.sh
curl -O https://raw.githubusercontent.com/nybble777/n8n-ai/main/scripts/rollback.sh
curl -O https://raw.githubusercontent.com/nybble777/n8n-ai/main/scripts/monitor.sh

chmod +x *.sh
```

---

## 📖 Использование

### Первая настройка:
```bash
./scripts/setup-server.sh
```

### Ручной деплой:
```bash
./scripts/deploy.sh
```

### Откат:
```bash
./scripts/rollback.sh
```

### Мониторинг:
```bash
nohup ./scripts/monitor.sh &
```

---

## ✅ Готово!

Теперь у вас есть полный набор для автодеплоя на свой сервер! 🎉

