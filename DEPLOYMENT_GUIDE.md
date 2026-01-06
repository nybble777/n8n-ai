# 🚀 Деплой n8n на бесплатные платформы

## 🎯 Сравнение платформ для деплоя

| Платформа | Бесплатно | Сложность | База данных | Рекомендация |
|-----------|-----------|-----------|-------------|--------------|
| **Fly.io** | ✅ 3 VM | 🟡 Средняя | PostgreSQL включен | ⭐⭐⭐⭐⭐ Лучший |
| **Render.com** | ✅ Да | 🟢 Легко | PostgreSQL включен | ⭐⭐⭐⭐⭐ Отлично |
| **Railway.app** | ⚠️ $5 кредит | 🟢 Легко | PostgreSQL включен | ⭐⭐⭐⭐ Хорошо |
| **Oracle Cloud** | ✅ Навсегда | 🔴 Сложно | Настроить самому | ⭐⭐⭐⭐⭐ Production |
| **Google Cloud Run** | ✅ Да | 🟡 Средняя | Нужна отдельно | ⭐⭐⭐ Serverless |

---

## 🏆 Способ 1: Fly.io (Рекомендуется)

### Преимущества:
- ✅ **Полностью бесплатно** (3 VM)
- ✅ PostgreSQL включен
- ✅ HTTPS автоматически
- ✅ Глобальная CDN
- ✅ Простой деплой из Docker

### Недостатки:
- ⚠️ Требует кредитную карту (не списывается)
- ⚠️ Может "засыпать" при отсутствии трафика

---

### 📋 Пошаговая инструкция Fly.io

#### Шаг 1: Установите flyctl

```bash
# macOS
brew install flyctl

# Или через curl
curl -L https://fly.io/install.sh | sh
```

#### Шаг 2: Войдите в аккаунт

```bash
# Регистрация/вход
flyctl auth signup
# или если уже есть аккаунт
flyctl auth login
```

#### Шаг 3: Создайте конфигурацию

Создайте файл `fly.toml` в корне проекта:

```toml
app = "n8n-prototype"
primary_region = "fra"  # Frankfurt, можно выбрать другой

[build]
  image = "n8nio/n8n:latest"

[env]
  N8N_PORT = "5678"
  N8N_PROTOCOL = "https"
  N8N_BASIC_AUTH_ACTIVE = "true"
  WEBHOOK_URL = "https://n8n-prototype.fly.dev"
  DB_TYPE = "postgresdb"
  GENERIC_TIMEZONE = "Europe/Moscow"
  EXECUTIONS_DATA_SAVE_ON_SUCCESS = "all"
  EXECUTIONS_DATA_SAVE_ON_ERROR = "all"

[http_service]
  internal_port = 5678
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  memory = "1gb"
  cpu_kind = "shared"
  cpus = 1

[mounts]
  source = "n8n_data"
  destination = "/home/node/.n8n"
```

#### Шаг 4: Создайте PostgreSQL базу данных

```bash
# Создайте базу данных (бесплатно)
flyctl postgres create --name n8n-db --region fra

# Подключите к приложению
flyctl postgres attach n8n-db -a n8n-prototype
```

Это автоматически создаст переменные окружения для подключения к БД.

#### Шаг 5: Установите секреты

```bash
# Установите пароль для n8n
flyctl secrets set N8N_BASIC_AUTH_USER=admin -a n8n-prototype
flyctl secrets set N8N_BASIC_AUTH_PASSWORD=your_strong_password -a n8n-prototype

# Сгенерируйте encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
flyctl secrets set N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY -a n8n-prototype
```

#### Шаг 6: Создайте volume для данных

```bash
flyctl volumes create n8n_data --size 1 --region fra -a n8n-prototype
```

#### Шаг 7: Деплой!

```bash
flyctl deploy
```

**Готово!** n8n будет доступен на: `https://n8n-prototype.fly.dev`

#### Шаг 8: Проверка

```bash
# Посмотреть статус
flyctl status -a n8n-prototype

# Посмотреть логи
flyctl logs -a n8n-prototype

# Открыть в браузере
flyctl open -a n8n-prototype
```

---

## 🎨 Способ 2: Render.com (Самый простой)

### Преимущества:
- ✅ **Самый простой** в настройке
- ✅ Бесплатный tier
- ✅ PostgreSQL включен
- ✅ HTTPS автоматически
- ✅ Автодеплой из Git

### Недостатки:
- ⚠️ "Засыпает" через 15 минут неактивности
- ⚠️ Медленный старт после "сна" (~30 сек)

---

### 📋 Пошаговая инструкция Render.com

#### Шаг 1: Подготовьте репозиторий

```bash
# Инициализируйте git (если еще не сделано)
cd /Users/nybble/projects/n8n
git init
git add .
git commit -m "Initial n8n setup"

# Создайте репозиторий на GitHub
# Затем:
git remote add origin https://github.com/your-username/n8n-prototype.git
git push -u origin main
```

#### Шаг 2: Создайте Dockerfile

Создайте `Dockerfile.render` в корне проекта:

```dockerfile
FROM n8nio/n8n:latest

# Переменные окружения будут установлены через Render UI
ENV NODE_ENV=production

# Expose port
EXPOSE 5678

# Start n8n
CMD ["n8n"]
```

#### Шаг 3: Зарегистрируйтесь на Render

1. Откройте: https://render.com
2. Sign Up (можно через GitHub)
3. Подключите ваш GitHub репозиторий

#### Шаг 4: Создайте PostgreSQL базу данных

1. Dashboard → New → PostgreSQL
2. Name: `n8n-db`
3. Plan: **Free**
4. Create Database
5. **Скопируйте Internal Database URL**

#### Шаг 5: Создайте Web Service

1. Dashboard → New → Web Service
2. Connect Repository → выберите ваш репозиторий
3. Настройки:
   - **Name:** `n8n-prototype`
   - **Region:** Frankfurt (или ближайший)
   - **Branch:** `main`
   - **Runtime:** Docker
   - **Dockerfile Path:** `Dockerfile.render`
   - **Plan:** **Free**

4. **Environment Variables** (добавьте):
   ```
   N8N_PORT=5678
   N8N_PROTOCOL=https
   N8N_HOST=n8n-prototype.onrender.com
   N8N_BASIC_AUTH_ACTIVE=true
   N8N_BASIC_AUTH_USER=admin
   N8N_BASIC_AUTH_PASSWORD=your_strong_password
   WEBHOOK_URL=https://n8n-prototype.onrender.com
   
   DB_TYPE=postgresdb
   DB_POSTGRESDB_HOST=[из Internal Database URL]
   DB_POSTGRESDB_PORT=5432
   DB_POSTGRESDB_DATABASE=[из Internal Database URL]
   DB_POSTGRESDB_USER=[из Internal Database URL]
   DB_POSTGRESDB_PASSWORD=[из Internal Database URL]
   
   N8N_ENCRYPTION_KEY=[сгенерируйте: openssl rand -base64 32]
   ```

5. Create Web Service

**Готово!** n8n будет доступен на: `https://n8n-prototype.onrender.com`

---

## 🚂 Способ 3: Railway.app

### Преимущества:
- ✅ Очень простой UI
- ✅ PostgreSQL включен
- ✅ Автодеплой из Git
- ✅ Отличная документация

### Недостатки:
- ⚠️ $5 trial credit (не полностью бесплатно)
- ⚠️ После trial - $5/месяц

---

### 📋 Пошаговая инструкция Railway.app

#### Шаг 1: Зарегистрируйтесь

1. Откройте: https://railway.app
2. Sign Up (через GitHub)

#### Шаг 2: Создайте проект

1. New Project
2. Deploy from GitHub repo
3. Выберите репозиторий

Или проще:

1. New Project → Deploy n8n (есть в templates!)
2. Configure:
   - PostgreSQL: Yes
   - Environment: Production

#### Шаг 3: Настройте переменные

Railway автоматически настроит PostgreSQL.

Добавьте:
```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_strong_password
N8N_PROTOCOL=https
WEBHOOK_URL=${{RAILWAY_PUBLIC_DOMAIN}}
N8N_ENCRYPTION_KEY=[сгенерируйте]
```

#### Шаг 4: Деплой

Railway автоматически задеплоит при push в Git.

**URL:** Будет показан в Dashboard

---

## 💎 Способ 4: Oracle Cloud (Always Free)

### Преимущества:
- ✅ **Бесплатно НАВСЕГДА**
- ✅ 2 VM с 1GB RAM
- ✅ 200GB storage
- ✅ Полный контроль
- ✅ Статический IP

### Недостатки:
- ⚠️ Сложная настройка
- ⚠️ Требует знаний Linux
- ⚠️ Нужна регистрация с картой

---

### 📋 Пошаговая инструкция Oracle Cloud

#### Шаг 1: Создайте аккаунт

1. https://www.oracle.com/cloud/free/
2. Sign Up (бесплатно, карта для верификации)
3. Выберите регион (ближайший к вам)

#### Шаг 2: Создайте VM

1. Menu → Compute → Instances
2. Create Instance
3. Name: `n8n-server`
4. Image: **Ubuntu 22.04** (Always Free Eligible)
5. Shape: **VM.Standard.E2.1.Micro** (Always Free)
6. Networking: Create new VCN (по умолчанию)
7. SSH Keys: Сгенерируйте или загрузите свой
8. Create

**Сохраните:**
- Public IP
- SSH private key

#### Шаг 3: Настройте Firewall

1. Instance → Subnet → Security List
2. Add Ingress Rule:
   - Source CIDR: `0.0.0.0/0`
   - Destination Port: `80,443,5678`
   - Protocol: TCP

В VM также:
```bash
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 5678 -j ACCEPT
sudo netfilter-persistent save
```

#### Шаг 4: Подключитесь к VM

```bash
ssh -i your-private-key ubuntu@YOUR_PUBLIC_IP
```

#### Шаг 5: Установите Docker

```bash
# Обновите систему
sudo apt update && sudo apt upgrade -y

# Установите Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавьте пользователя в группу docker
sudo usermod -aG docker ubuntu

# Установите Docker Compose
sudo apt install docker-compose -y

# Перелогиньтесь
exit
ssh -i your-private-key ubuntu@YOUR_PUBLIC_IP
```

#### Шаг 6: Перенесите проект

```bash
# На вашем компьютере
scp -i your-private-key -r /Users/nybble/projects/n8n ubuntu@YOUR_PUBLIC_IP:~/

# На сервере
cd ~/n8n
```

#### Шаг 7: Настройте docker-compose для production

Отредактируйте `docker-compose.yml`:

```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-prototype
    restart: always
    ports:
      - "80:5678"  # HTTP
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_strong_password
      - N8N_HOST=YOUR_PUBLIC_IP
      - N8N_PORT=5678
      - N8N_PROTOCOL=http  # Позже настроим HTTPS
      - WEBHOOK_URL=http://YOUR_PUBLIC_IP
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n_password
      - N8N_ENCRYPTION_KEY=your_encryption_key
    volumes:
      - ./n8n-data:/home/node/.n8n
    depends_on:
      - postgres
    networks:
      - n8n-network

  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: always
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - n8n-network

volumes:
  postgres-data:

networks:
  n8n-network:
```

#### Шаг 8: Запустите

```bash
docker-compose up -d
```

**n8n доступен на:** `http://YOUR_PUBLIC_IP`

#### Шаг 9: Настройте HTTPS (опционально, но рекомендуется)

```bash
# Установите Caddy (простой reverse proxy с auto-HTTPS)
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Настройте Caddy
sudo nano /etc/caddy/Caddyfile
```

Добавьте:
```
your-domain.com {
    reverse_proxy localhost:5678
}
```

```bash
# Перезапустите Caddy
sudo systemctl restart caddy
```

Измените в docker-compose.yml:
```yaml
- N8N_PROTOCOL=https
- WEBHOOK_URL=https://your-domain.com
```

```bash
docker-compose restart
```

---

## 🌊 Способ 5: Google Cloud Run (Serverless)

### Преимущества:
- ✅ Бесплатный tier (2M requests/месяц)
- ✅ Автомасштабирование
- ✅ Платите только за использование

### Недостатки:
- ⚠️ Сложная настройка
- ⚠️ Не подходит для long-running workflows
- ⚠️ База данных нужна отдельно

Создам отдельный гайд если интересно.

---

## ⚠️ Почему НЕТ Vercel/Netlify?

### Vercel и Netlify - НЕ подходят для n8n

**Причины:**

#### 1. **Serverless архитектура vs Long-Running Process**
```
Vercel/Netlify:
└─ Оптимизированы для: Serverless Functions (короткие запросы)
└─ Лимит выполнения: 10 сек (Hobby), 300 сек (Pro)

n8n:
└─ Требуется: Постоянно работающий процесс
└─ Workflow могут выполняться часами
└─ WebSocket соединения для UI
```

#### 2. **Хранение состояния**
```
Vercel/Netlify:
└─ Ephemeral storage (удаляется после выполнения)
└─ Нет persistent volumes

n8n:
└─ Требуется: Постоянное хранилище для:
   - База данных
   - Executions history
   - Uploaded files
   - Custom nodes
```

#### 3. **Execution Limits**
```
Vercel Free tier:
- 10 секунд timeout
- 100GB bandwidth/месяц
- Serverless functions: 100 часов/месяц

n8n типичное использование:
- Некоторые workflow работают минуты/часы
- WebSocket соединения постоянно открыты
- Scheduled workflows запускаются регулярно
```

#### 4. **База данных**
```
Vercel/Netlify:
- Нет встроенной БД
- Нужна внешняя (Vercel Postgres - платно от $20/месяц)

Fly.io/Render:
- PostgreSQL включен бесплатно
```

---

### Можно ли вообще запустить n8n на Vercel?

**Технически - ДА, но с серьезными ограничениями:**

```dockerfile
# Можно задеплоить как Docker container
# Но столкнетесь с:
- ⚠️ Засыпание после каждого запроса
- ⚠️ Холодный старт 10-30 секунд
- ⚠️ Timeout на long-running workflows
- ⚠️ Нет persistent storage
- ⚠️ Дорого (нужна Pro подписка)
```

---

### Что использовать вместо Vercel?

| Для чего | Используйте | Почему |
|----------|-------------|--------|
| **Frontend для n8n** | Vercel ✅ | Отлично подходит для SPA |
| **n8n backend** | Fly.io / Render ❌ | Нужен long-running process |
| **API обертка над n8n** | Vercel Functions ✅ | Короткие запросы к n8n API |
| **Полный n8n** | НЕ Vercel ❌ | Используйте Fly.io/Render/VPS |

---

### Альтернатива: Hybrid подход

Можно комбинировать:

```
Vercel (Frontend)
└─ Ваш UI/Dashboard
└─ Обращается к API →

Fly.io/Render (Backend)
└─ n8n работает постоянно
└─ Обрабатывает workflow
└─ Предоставляет API
```

**Пример:**
```javascript
// На Vercel (Next.js API Route)
export default async function handler(req, res) {
  // Обращаемся к n8n на Fly.io
  const response = await fetch('https://your-n8n.fly.dev/api/v1/workflows', {
    headers: {
      'X-N8N-API-KEY': process.env.N8N_API_KEY
    }
  });
  
  const data = await response.json();
  res.json(data);
}
```

---

### Итого: Vercel vs n8n

```
❌ НЕ рекомендуется потому что:
   - Serverless архитектура несовместима с n8n
   - Дорого (нужна Pro + внешняя БД)
   - Множество ограничений
   - Плохой user experience (холодные старты)

✅ ВМЕСТО этого используйте:
   - Fly.io - если нужна скорость деплоя
   - Render.com - если нужна простота
   - Oracle Cloud - если нужна стабильность навсегда
```

---

## 📊 Сравнение по критериям

### Для прототипирования:
→ **Render.com** (проще всего)

### Для маленького проекта:
→ **Fly.io** (хороший баланс)

### Для production:
→ **Oracle Cloud** (полный контроль + бесплатно навсегда)

### Для команды:
→ **Railway.app** (удобный UI)

---

## ⚡ Автоматизация деплоя

### Создайте скрипт для автоматического деплоя

Создам `deploy.sh`:

```bash
#!/bin/bash

echo "🚀 Деплой n8n"
echo ""
echo "Выберите платформу:"
echo "1) Fly.io"
echo "2) Render.com (требует git push)"
echo "3) Railway (требует git push)"
echo ""
read -p "Ваш выбор: " choice

case $choice in
    1)
        echo "Деплой на Fly.io..."
        flyctl deploy
        ;;
    2)
        echo "Для Render.com сделайте:"
        echo "git add ."
        echo "git commit -m 'Deploy'"
        echo "git push"
        ;;
    3)
        echo "Для Railway сделайте:"
        echo "git add ."
        echo "git commit -m 'Deploy'"
        echo "git push"
        ;;
esac
```

---

## 🔒 Чек-лист безопасности для деплоя

Перед деплоем убедитесь:

- [ ] `N8N_BASIC_AUTH_ACTIVE=true`
- [ ] Надежный пароль установлен
- [ ] `N8N_ENCRYPTION_KEY` сгенерирован
- [ ] PostgreSQL вместо SQLite (для production)
- [ ] HTTPS настроен
- [ ] `WEBHOOK_URL` правильный
- [ ] Регулярные бэкапы настроены
- [ ] Переменные окружения в секретах (не в коде)

---

## 💰 Стоимость

| Платформа | Бесплатный tier | Ограничения |
|-----------|----------------|-------------|
| Fly.io | 3 VM (256MB RAM) | Может засыпать |
| Render.com | Unlimited | Засыпает через 15 мин |
| Railway | $5 credit | Потом $5/месяц |
| Oracle Cloud | 2 VM (1GB RAM) | Навсегда бесплатно! |
| Google Cloud Run | 2M requests | Нужна БД отдельно |

---

## 🆘 Помощь

### Если нужны подробные инструкции:

Скажите для какой платформы и я создам:
- Детальный step-by-step гайд
- Конфигурационные файлы
- Скрипты автоматизации
- CI/CD настройку

---

## 📚 Дополнительные ресурсы

- [n8n Self-Hosting Guide](https://docs.n8n.io/hosting/)
- [Fly.io Docs](https://fly.io/docs/)
- [Render.com Docs](https://render.com/docs)
- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)

---

**Выберите платформу и начинайте деплой! 🚀**

