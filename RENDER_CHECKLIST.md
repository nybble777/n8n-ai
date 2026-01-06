# ✅ Чек-лист деплоя n8n на Render.com

## Статус: В процессе

### ✅ Уже сделано:

- [x] Проект создан
- [x] Docker конфигурации готовы (Dockerfile.render)
- [x] Git репозиторий инициализирован
- [x] Изменения закоммичены
- [x] GitHub репозиторий существует: https://github.com/nybble777/n8n-ai.git

### 📋 Нужно сделать:

- [ ] **Push в GitHub** (СЕЙЧАС)
  ```bash
  cd /Users/nybble/projects/n8n
  git push origin main
  ```

- [ ] **Зарегистрироваться на Render.com**
  - Откройте: https://render.com
  - Sign Up (через GitHub быстрее!)
  - **Карта НЕ требуется!**

- [ ] **Создать PostgreSQL базу**
  - Dashboard → New → PostgreSQL
  - Name: `n8n-db`
  - Region: Frankfurt
  - Plan: **Free**
  - Create Database
  - **Скопировать Internal Database URL**

- [ ] **Создать Web Service**
  - Dashboard → New → Web Service
  - Connect Repository → `nybble777/n8n-ai`
  - Name: `n8n-ai`
  - Region: Frankfurt
  - Runtime: Docker
  - Dockerfile: `./Dockerfile.render`
  - Plan: **Free**

- [ ] **Добавить переменные окружения**
  
  Сгенерируйте пароль и ключ:
  ```bash
  openssl rand -base64 20  # Пароль
  openssl rand -base64 32  # Encryption key
  ```
  
  Добавьте в Render (Advanced → Environment Variables):
  ```
  N8N_PORT=5678
  N8N_PROTOCOL=https
  N8N_HOST=n8n-ai.onrender.com
  N8N_BASIC_AUTH_ACTIVE=true
  N8N_BASIC_AUTH_USER=admin
  N8N_BASIC_AUTH_PASSWORD=[ваш пароль]
  WEBHOOK_URL=https://n8n-ai.onrender.com
  
  DB_TYPE=postgresdb
  DATABASE_URL=[Internal Database URL из PostgreSQL]
  
  N8N_ENCRYPTION_KEY=[ваш encryption key]
  
  GENERIC_TIMEZONE=Europe/Moscow
  NODE_ENV=production
  ```

- [ ] **Деплой!**
  - Нажать "Create Web Service"
  - Ждать 3-5 минут

- [ ] **Открыть n8n**
  - URL: https://n8n-ai.onrender.com
  - Login: admin
  - Password: (тот что сгенерировали)

---

## 💡 Подсказки

### Генерация паролей (скопируйте и выполните):

```bash
echo "Пароль для N8N:"
openssl rand -base64 20

echo ""
echo "Encryption Key:"
openssl rand -base64 32
```

Сохраните эти значения - они понадобятся!

### Если застряли:

- **Полная инструкция:** `TRY_RENDER_INSTEAD.md`
- **Скриншоты и детали:** Там есть всё пошагово

### Render.com Dashboard:

- https://dashboard.render.com

### Ваш GitHub репозиторий:

- https://github.com/nybble777/n8n-ai

---

## 🎉 После деплоя

n8n будет доступен на: `https://n8n-ai.onrender.com`

**Важно:**
- Засыпает через 15 минут неактивности
- Первый запрос после сна: ~30 секунд
- Решение: UptimeRobot (бесплатный пинг)

---

## ⏱️ Примерное время

- Push в GitHub: 1 минута
- Регистрация Render: 2 минуты
- Создание PostgreSQL: 1 минута
- Создание Web Service: 2 минуты
- Первый деплой: 3-5 минут

**Итого: ~10 минут**

---

**Следующий шаг: Push в GitHub!**

```bash
cd /Users/nybble/projects/n8n
git push origin main
```

