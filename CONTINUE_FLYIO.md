# 🚀 Продолжение деплоя на Fly.io

## После добавления карты

### Шаг 1: Добавьте карту

Откройте: https://fly.io/dashboard/a-s-alexeev-mail-ru/billing

1. Нажмите "Add Payment Method"
2. Введите данные карты
3. Сохраните

⚠️ **Списаний не будет** пока вы в бесплатном tier!

---

### Шаг 2: Продолжите деплой

```bash
cd /Users/nybble/projects/n8n

# Создайте приложение
flyctl launch --no-deploy --copy-config

# Выберите:
# - Region: fra (Frankfurt) или ближайший
# - Confirm: Yes
```

---

### Шаг 3: Создайте PostgreSQL

```bash
# Создайте базу данных
flyctl postgres create --name n8n-db --region fra

# Выберите:
# - Configuration: Development (бесплатно)
# - 1GB volume
```

---

### Шаг 4: Подключите БД

```bash
# Узнайте имя вашего приложения
flyctl apps list

# Подключите БД (замените YOUR_APP на имя приложения)
flyctl postgres attach n8n-db --app YOUR_APP
```

---

### Шаг 5: Создайте volume

```bash
flyctl volumes create n8n_data --size 1 --region fra --app YOUR_APP
```

---

### Шаг 6: Установите секреты

```bash
# Генерируем пароли
PASSWORD=$(openssl rand -base64 20)
ENCRYPTION_KEY=$(openssl rand -base64 32)

echo "Ваш пароль: $PASSWORD"
echo "Encryption key: $ENCRYPTION_KEY"
echo ""
echo "СОХРАНИТЕ ЭТИ ЗНАЧЕНИЯ!"

# Установите секреты
flyctl secrets set N8N_BASIC_AUTH_ACTIVE=true --app YOUR_APP
flyctl secrets set N8N_BASIC_AUTH_USER=admin --app YOUR_APP
flyctl secrets set N8N_BASIC_AUTH_PASSWORD="$PASSWORD" --app YOUR_APP
flyctl secrets set N8N_ENCRYPTION_KEY="$ENCRYPTION_KEY" --app YOUR_APP
```

---

### Шаг 7: Деплой!

```bash
flyctl deploy --app YOUR_APP
```

---

### Шаг 8: Откройте n8n

```bash
flyctl open --app YOUR_APP
```

URL будет: `https://YOUR_APP.fly.dev`

**Логин:**
- Username: `admin`
- Password: (тот что сгенерировали в шаге 6)

---

## ✅ Готово!

n8n работает на Fly.io!

**Полезные команды:**
```bash
flyctl logs --app YOUR_APP           # Логи
flyctl status --app YOUR_APP         # Статус
flyctl scale show --app YOUR_APP     # Ресурсы
```

**Обновление:**
```bash
flyctl deploy --app YOUR_APP
```

**Стоимость:** $0/месяц (пока в бесплатном tier)

📖 Полная документация: FLYIO_DEPLOY_STEPS.md

