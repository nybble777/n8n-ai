.PHONY: help start stop restart logs backup restore clean update

help: ## Показать эту справку
	@echo "Доступные команды для n8n прототипирования:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

start: ## Запустить n8n
	@echo "🚀 Запускаю n8n..."
	@docker-compose up -d
	@echo "✅ n8n запущен на http://localhost:5678"

stop: ## Остановить n8n
	@echo "⏸️  Останавливаю n8n..."
	@docker-compose down
	@echo "✅ n8n остановлен"

restart: ## Перезапустить n8n
	@echo "🔄 Перезапускаю n8n..."
	@docker-compose restart
	@echo "✅ n8n перезапущен"

logs: ## Показать логи n8n
	@docker-compose logs -f n8n

status: ## Показать статус контейнера
	@docker-compose ps

backup: ## Создать резервную копию workflow
	@echo "💾 Создаю резервную копию..."
	@mkdir -p backups
	@docker exec n8n-prototype n8n export:workflow --all --output=/backups/workflows-$$(date +%Y%m%d_%H%M%S).json 2>/dev/null || echo "⚠️  Нет workflow для экспорта"
	@echo "✅ Резервная копия создана в backups/"

restore: ## Восстановить workflow из последней резервной копии
	@echo "📥 Восстанавливаю workflow..."
	@LATEST=$$(ls -t backups/workflows-*.json 2>/dev/null | head -1); \
	if [ -n "$$LATEST" ]; then \
		docker exec n8n-prototype n8n import:workflow --input=/backups/$$(basename $$LATEST); \
		echo "✅ Workflow восстановлены из $$LATEST"; \
	else \
		echo "❌ Нет резервных копий для восстановления"; \
	fi

clean: ## Полная очистка (удалить все данные)
	@echo "⚠️  ВНИМАНИЕ: Это удалит ВСЕ данные n8n!"
	@read -p "Продолжить? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "🗑️  Удаляю данные..."; \
		docker-compose down -v; \
		rm -rf n8n-data/; \
		echo "✅ Данные удалены"; \
	else \
		echo "❌ Отменено"; \
	fi

update: ## Обновить n8n до последней версии
	@echo "⬆️  Обновляю n8n..."
	@docker-compose pull
	@docker-compose up -d
	@echo "✅ n8n обновлен"

shell: ## Открыть shell в контейнере n8n
	@docker exec -it n8n-prototype /bin/sh

setup: ## Первоначальная настройка проекта
	@echo "⚙️  Настраиваю проект..."
	@mkdir -p n8n-data backups custom-nodes
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Создан файл .env"; fi
	@echo "✅ Проект настроен! Запустите 'make start' для начала работы"

dev: start logs ## Запустить и показать логи (режим разработки)

info: ## Показать информацию о проекте
	@echo "📊 Информация о проекте n8n"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "URL:           http://localhost:5678"
	@echo "Данные:        ./n8n-data/"
	@echo "Резервные копии: ./backups/"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@docker-compose ps

public: ## Сделать n8n доступным из интернета
	@./start-public.sh

