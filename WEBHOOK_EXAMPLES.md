# 🔗 Примеры работы с Webhook

## 📋 Базовая информация

После импорта `examples/example-workflow-webhook.json`:

- **Test URL**: `http://localhost:5678/webhook-test/test-webhook`
- **Production URL**: `http://localhost:5678/webhook/test-webhook`

⚠️ **Важно**: Не забудьте **активировать workflow** (переключатель "Active" в правом верхнем углу)!

---

## 🚀 Способы отправки POST запроса

### 1. Готовый скрипт (рекомендуется)

```bash
./test-my-webhook.sh
```

Или используйте универсальный скрипт:

```bash
./scripts/test-webhook.sh test-webhook
```

---

### 2. cURL (простой вариант)

```bash
curl -X POST http://localhost:5678/webhook-test/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"message": "Привет из curl!"}'
```

### 3. cURL (с красивым JSON)

```bash
curl -X POST http://localhost:5678/webhook-test/test-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Тестовое сообщение",
    "data": {
      "id": 123,
      "value": "test"
    }
  }' | jq '.'
```

### 4. cURL (с заголовками)

```bash
curl -X POST http://localhost:5678/webhook-test/test-webhook \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "X-Custom-Header: CustomValue" \
  -d '{"message": "С кастомными заголовками"}' \
  -v  # verbose - показать все детали
```

---

### 5. HTTPie (более читаемый)

Если установлен [HTTPie](https://httpie.io/):

```bash
# Установка (если нужно)
brew install httpie

# Простой запрос
http POST http://localhost:5678/webhook-test/test-webhook \
  message="Привет из HTTPie" \
  value:=123

# С JSON файлом
http POST http://localhost:5678/webhook-test/test-webhook < data.json
```

---

### 6. Python

```python
import requests
import json

url = "http://localhost:5678/webhook-test/test-webhook"
headers = {
    "Content-Type": "application/json"
}
data = {
    "message": "Привет из Python!",
    "data": {
        "id": 123,
        "value": "test"
    }
}

response = requests.post(url, headers=headers, json=data)
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}")
```

Сохраните как `test_webhook.py` и запустите:

```bash
python3 test_webhook.py
```

---

### 7. JavaScript / Node.js

```javascript
// test_webhook.js
const fetch = require('node-fetch');

const url = 'http://localhost:5678/webhook-test/test-webhook';
const data = {
  message: 'Привет из Node.js!',
  data: {
    id: 123,
    value: 'test'
  }
};

fetch(url, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(data),
})
  .then(response => response.json())
  .then(data => {
    console.log('Status:', response.status);
    console.log('Response:', data);
  })
  .catch(error => console.error('Error:', error));
```

Запуск:

```bash
node test_webhook.js
```

---

### 8. JavaScript (современный с async/await)

```javascript
// test_webhook_modern.js
async function testWebhook() {
  const url = 'http://localhost:5678/webhook-test/test-webhook';
  const data = {
    message: 'Привет из современного JS!',
    timestamp: new Date().toISOString()
  };

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    const result = await response.json();
    console.log('✅ Успешно!');
    console.log('Ответ:', result);
  } catch (error) {
    console.error('❌ Ошибка:', error.message);
  }
}

testWebhook();
```

---

### 9. Postman

1. Создайте новый Request
2. Метод: **POST**
3. URL: `http://localhost:5678/webhook-test/test-webhook`
4. Headers:
   - `Content-Type: application/json`
5. Body → raw → JSON:
   ```json
   {
     "message": "Привет из Postman!",
     "data": {
       "id": 123,
       "value": "test"
     }
   }
   ```
6. Нажмите **Send**

---

### 10. Insomnia

1. New Request → POST
2. URL: `http://localhost:5678/webhook-test/test-webhook`
3. Body → JSON:
   ```json
   {
     "message": "Привет из Insomnia!"
   }
   ```
4. Send

---

### 11. VS Code REST Client

Создайте файл `webhook.http`:

```http
### Test Webhook
POST http://localhost:5678/webhook-test/test-webhook
Content-Type: application/json

{
  "message": "Привет из VS Code!",
  "timestamp": "2024-01-06T12:00:00Z",
  "data": {
    "id": 123,
    "value": "test"
  }
}
```

Нажмите "Send Request" над запросом.

---

### 12. wget

```bash
wget --post-data='{"message":"Привет из wget!"}' \
  --header='Content-Type: application/json' \
  http://localhost:5678/webhook-test/test-webhook \
  -O - -q
```

---

## 🧪 Примеры данных для тестирования

### Простой объект

```json
{
  "message": "Тестовое сообщение"
}
```

### Вложенные данные

```json
{
  "user": {
    "id": 123,
    "name": "Иван",
    "email": "ivan@example.com"
  },
  "action": "create",
  "timestamp": "2024-01-06T12:00:00Z"
}
```

### Массив данных

```json
{
  "items": [
    {"id": 1, "name": "Item 1"},
    {"id": 2, "name": "Item 2"},
    {"id": 3, "name": "Item 3"}
  ],
  "total": 3
}
```

### Сложная структура

```json
{
  "event": "order.created",
  "data": {
    "order_id": "ORD-12345",
    "customer": {
      "name": "Иван Иванов",
      "email": "ivan@example.com"
    },
    "items": [
      {
        "product_id": "PROD-1",
        "quantity": 2,
        "price": 1000
      }
    ],
    "total": 2000,
    "currency": "RUB"
  },
  "timestamp": "2024-01-06T12:00:00Z"
}
```

---

## 🔍 Отладка

### Проверка доступности webhook

```bash
curl -I http://localhost:5678/webhook-test/test-webhook
```

### Посмотреть полный ответ с заголовками

```bash
curl -v -X POST http://localhost:5678/webhook-test/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

### Проверить логи n8n

```bash
make logs
# или
docker logs n8n-prototype -f
```

---

## ❌ Частые ошибки

### 404 Not Found

**Причины:**
- Workflow не активирован
- Неправильный путь в URL
- Workflow не импортирован

**Решение:**
1. Убедитесь, что workflow активен (зеленая галочка "Active")
2. Проверьте URL в узле Webhook
3. Используйте Test URL для тестирования

### 500 Internal Server Error

**Причины:**
- Ошибка в Function узле
- Проблема с обработкой данных

**Решение:**
1. Проверьте логи: `make logs`
2. Упростите Function код для тестирования
3. Проверьте формат отправляемых данных

### Connection Refused

**Причины:**
- n8n не запущен
- Неправильный порт

**Решение:**
1. Проверьте статус: `docker ps`
2. Запустите n8n: `make start`
3. Убедитесь, что используете порт 5678

---

## 💡 Советы

1. **Используйте Test URL** во время разработки
2. **Логируйте данные** в Function узле для отладки
3. **Делайте бэкапы** перед изменениями: `make backup`
4. **Тестируйте постепенно** - сначала простые данные, потом сложные

---

## 🔗 Дополнительно

### Получение Production URL

После активации workflow, Production URL будет:
```
http://localhost:5678/webhook/test-webhook
```

### Использование переменных в curl

```bash
WEBHOOK_URL="http://localhost:5678/webhook-test/test-webhook"
MESSAGE="Тестовое сообщение"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"$MESSAGE\"}"
```

### Массовое тестирование

```bash
for i in {1..5}; do
  curl -X POST http://localhost:5678/webhook-test/test-webhook \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"Test $i\", \"id\": $i}"
  sleep 1
done
```

---

**Готово! Выберите удобный способ и начинайте тестировать! 🚀**

