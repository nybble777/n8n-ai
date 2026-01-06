# ⚡ Как активировать workflow

## 🎯 Простая пошаговая инструкция

### 1️⃣ Откройте n8n
```
http://localhost:5678
```

### 2️⃣ Найдите workflow
Вы увидите список workflows. Найдите:
- **"Пример: Webhook обработчик"**

### 3️⃣ Откройте workflow
Кликните на название workflow

### 4️⃣ Активируйте workflow
В **правом верхнем углу** экрана найдите переключатель:
```
┌─────────────────────────────────────┐
│                      [Inactive] ←── Кликните сюда
└─────────────────────────────────────┘
```

После клика он должен стать:
```
┌─────────────────────────────────────┐
│                      [Active] ✓ ←── Зеленый
└─────────────────────────────────────┘
```

### 5️⃣ Готово! Теперь протестируйте

```bash
cd /Users/nybble/projects/n8n

# Тест с простым curl
curl -X POST http://localhost:5678/webhook/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"message": "Привет!", "value": 123}'

# Или используйте скрипт
# (но сначала обновите URL в test-my-webhook.sh)
```

---

## 📊 Разница между Test и Production URL

### Test URL: `/webhook-test/test-webhook`
- ✅ Для отладки
- ⚠️  Работает только ОДИН раз после нажатия "Execute workflow"
- ⚠️  Требует ручной активации для каждого теста
- 🎯 Использовать: при разработке workflow

### Production URL: `/webhook/test-webhook`
- ✅ Для постоянной работы
- ✅ Работает автоматически
- ✅ Требует активации workflow один раз
- 🎯 Использовать: для реального использования

---

## ✅ Проверка что все работает

После активации workflow выполните:

```bash
# Проверка
curl -X POST http://localhost:5678/webhook/test-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true, "message": "Работает!"}' \
  | jq '.'
```

Ожидаемый ответ (HTTP 200):
```json
{
  "message": "Webhook получен успешно",
  "receivedData": {
    "test": true,
    "message": "Работает!"
  },
  "timestamp": "2024-01-06T...",
  "source": "curl/..."
}
```

---

## 🔧 Обновите скрипт

После активации, обновите `test-my-webhook.sh` чтобы использовать Production URL:

```bash
# Измените строку 5 с:
WEBHOOK_URL="http://localhost:5678/webhook-test/test-webhook"

# На:
WEBHOOK_URL="http://localhost:5678/webhook/test-webhook"
```

---

## 📸 Визуально

```
┌────────────────────────────────────────────────────────┐
│  n8n  │  Пример: Webhook обработчик      [Inactive] ← │
├────────────────────────────────────────────────────────┤
│                                                        │
│    ┌─────────┐      ┌──────────┐      ┌─────────┐    │
│    │ Webhook │ ───→ │ Function │ ───→ │ Respond │    │
│    └─────────┘      └──────────┘      └─────────┘    │
│                                                        │
└────────────────────────────────────────────────────────┘

Кликните на [Inactive] → должно стать [Active] ✓
```

---

## 💡 Советы

1. **Активированный workflow = зеленая галочка** в списке workflows
2. **Неактивный workflow = серый** в списке
3. **Production webhook** работает только для активных workflows
4. **Test webhook** нужен только для отладки
5. **Не забывайте сохранять** изменения в workflow перед активацией

---

## 🚀 Быстрая команда после активации

```bash
# Создайте алиас для быстрого тестирования
alias test-webhook='curl -X POST http://localhost:5678/webhook/test-webhook -H "Content-Type: application/json" -d'"'"'{"message":"test"}'"'"' | jq "."'

# Теперь можно просто:
test-webhook
```

---

**После активации webhook будет работать постоянно! 🎉**

