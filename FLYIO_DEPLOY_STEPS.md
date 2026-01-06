# 🚀 Деплой n8n на Fly.io - Пошаговая инструкция

## ✅ Что будет создано:

- n8n приложение на Fly.io
- PostgreSQL база данных (бесплатно)
- HTTPS автоматически
- Постоянный URL: `https://your-app.fly.dev`

---

## 📋 Шаг за шагом

### Шаг 1: Установите flyctl

```bash
# macOS
brew install flyctl

# Проверьте установку
flyctl version
```

### Шаг 2: Создайте аккаунт и войдите

```bash
# Регистрация (если первый раз)
flyctl auth signup

# Или вход (если уже есть аккаунт)
flyctl auth login
```

Откроется браузер для авторизации.

⚠️ **Потребуется кредитная карта** (для верификации, не списывается в бесплатном tier)

### Шаг 3: Проверьте конфигурацию

Файл `fly.toml` уже готов! Но измените название приложения на уникальное:

```bash
# Откройте fly.toml и измените:
app = "n8n-ai"  # ← Измените на уникальное имя
                       # Например: "n8n-myname" или "n8n-test123"
```

### Шаг 4: Создайте приложение

```bash
cd /Users/nybble/projects/n8n

# Создайте приложение на основе fly.toml
flyctl launch --no-deploy

# Выберите:
# - Region: fra (Frankfurt) или ближайший к вам
# - PostgreSQL: NO (создадим отдельно на следующем шаге)
# - Deploy: NO (деплоим позже вручную)
```

### Шаг 5: Создайте PostgreSQL базу данных

```bash
# Создайте бесплатную PostgreSQL базу
flyctl postgres create --name n8n-db --region fra --initial-cluster-size 1

# Выберите:
# - Configuration: Development (256MB RAM) - бесплатно
# - Scale: 1GB volume
```

Сохраните информацию о подключении (она понадобится).

### Шаг 6: Подключите базу данных к приложению

```bash
# Замените YOUR_APP на имя вашего приложения из fly.toml
flyctl postgres attach n8n-db --app YOUR_APP
```

Это автоматически создаст переменную `DATABASE_URL`.

### Шаг 7: Создайте volume для данных

```bash
flyctl volumes create n8n_data --size 1 --region fra --app YOUR_APP
```

### Шаг 8: Установите секреты (ВАЖНО!)

```bash
# Генерируем пароль
PASSWORD=$(openssl rand -base64 20)
echo "Ваш пароль (сохраните!): $PASSWORD"

# Генерируем encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "Encryption key (сохраните!): $ENCRYPTION_KEY"

# Установите секреты
flyctl secrets set N8N_BASIC_AUTH_ACTIVE=true --app YOUR_APP
flyctl secrets set N8N_BASIC_AUTH_USER=admin --app YOUR_APP
flyctl secrets set N8N_BASIC_AUTH_PASSWORD="$PASSWORD" --app YOUR_APP
flyctl secrets set N8N_ENCRYPTION_KEY="$ENCRYPTION_KEY" --app YOUR_APP
```

⚠️ **СОХРАНИТЕ** эти значения! Они понадобятся для входа.

### Шаг 9: Деплой!

```bash
# Первый деплой (может занять 2-3 минуты)
flyctl deploy --app YOUR_APP
```

### Шаг 10: Проверка

```bash
# Посмотрите статус
flyctl status --app YOUR_APP

# Откройте в браузере
flyctl open --app YOUR_APP

# Или вручную:
# https://YOUR_APP.fly.dev
```

### Шаг 11: Войдите в n8n

Откроется окно авторизации:
- **Username:** `admin`
- **Password:** (тот что вы сгенерировали в шаге 8)

---

## ✅ Готово!

n8n работает на: `https://YOUR_APP.fly.dev`

---

## 🔧 Полезные команды

```bash
# Посмотреть логи
flyctl logs --app YOUR_APP

# Посмотреть логи в реальном времени
flyctl logs -f --app YOUR_APP

# Посмотреть статус
flyctl status --app YOUR_APP

# Открыть в браузере
flyctl open --app YOUR_APP

# SSH в контейнер (для отладки)
flyctl ssh console --app YOUR_APP

# Посмотреть использование ресурсов
flyctl scale show --app YOUR_APP

# Посмотреть секреты (значения скрыты)
flyctl secrets list --app YOUR_APP

# Проверить PostgreSQL
flyctl postgres connect -a n8n-db
```

---

## 🔄 Обновление n8n

```bash
# Просто задеплойте снова
flyctl deploy --app YOUR_APP

# Fly.io скачает последнюю версию n8nio/n8n:latest
```

---

## 💾 Резервные копии

### Бэкап PostgreSQL:

```bash
# Подключитесь к базе
flyctl postgres connect -a n8n-db

# Внутри PostgreSQL:
\dt  # Список таблиц
\q   # Выход
```

Для автоматических бэкапов Fly.io делает снапшоты volumes ежедневно.

### Экспорт workflow:

```bash
# SSH в контейнер
flyctl ssh console --app YOUR_APP

# Внутри контейнера:
n8n export:workflow --all --output=/tmp/workflows.json
cat /tmp/workflows.json

# Скопируйте вывод и сохраните локально
```

---

## 📊 Мониторинг

```bash
# Метрики приложения
flyctl dashboard --app YOUR_APP

# Посмотреть в веб-интерфейсе
# https://fly.io/apps/YOUR_APP
```

---

## 🐛 Решение проблем

### Приложение не запускается

```bash
# Посмотрите логи
flyctl logs --app YOUR_APP

# Проверьте статус
flyctl status --app YOUR_APP

# Проверьте health checks
flyctl checks list --app YOUR_APP
```

### База данных не подключается

```bash
# Проверьте что база подключена
flyctl postgres list

# Проверьте переменные окружения
flyctl secrets list --app YOUR_APP
```

### Volume проблемы

```bash
# Список volumes
flyctl volumes list --app YOUR_APP

# Если нужно, создайте заново
flyctl volumes destroy vol_xxx --app YOUR_APP
flyctl volumes create n8n_data --size 1 --app YOUR_APP
```

---

## 💰 Стоимость

**Бесплатный tier включает:**
- 3 shared-cpu-1x VM (256MB RAM)
- 3GB persistent volume storage
- 160GB outbound data transfer

**Ваш n8n использует:**
- 1 VM (256MB → можно увеличить до 1GB в бесплатном tier)
- 1GB volume
- PostgreSQL (256MB)

**Итого: $0/месяц** ✅

Если понадобится больше ресурсов:
- 1GB RAM VM: ~$7/месяц
- Дополнительный volume: $0.15/GB/месяц

---

## 🔐 Безопасность

### Изменить пароль:

```bash
NEW_PASSWORD=$(openssl rand -base64 20)
echo "Новый пароль: $NEW_PASSWORD"

flyctl secrets set N8N_BASIC_AUTH_PASSWORD="$NEW_PASSWORD" --app YOUR_APP
```

### Добавить IP whitelist (требует Fly.io платный план):

В `fly.toml` добавьте:
```toml
[services]
  [[services.checks]]
    type = "http"
    
  [[services.http_checks]]
    allowed_public_ips = ["YOUR_IP/32"]
```

---

## 🌍 Кастомный домен

```bash
# Добавить ваш домен
flyctl certs create your-domain.com --app YOUR_APP

# Получить DNS записи
flyctl certs show your-domain.com --app YOUR_APP

# Добавьте в вашем DNS провайдере:
# A record: @ → fly.io IP
# AAAA record: @ → fly.io IPv6
```

Затем обновите в `fly.toml`:
```toml
[env]
  N8N_HOST = "your-domain.com"
  WEBHOOK_URL = "https://your-domain.com"
```

И задеплойте снова:
```bash
flyctl deploy --app YOUR_APP
```

---

## 📚 Дополнительные ресурсы

- [Fly.io Docs](https://fly.io/docs/)
- [Fly.io PostgreSQL](https://fly.io/docs/postgres/)
- [n8n Documentation](https://docs.n8n.io/)

---

**Готово! Ваш n8n работает на Fly.io! 🎉**

