.PHONY: help

help: ## Hiển thị help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Application
app-up: ## Start application
	docker-compose -f docker-compose.app.yml up -d

app-down: ## Stop application
	docker-compose -f docker-compose.app.yml down

app-restart: ## Restart application
	docker-compose -f docker-compose.app.yml restart

app-logs: ## Xem logs application
	docker-compose -f docker-compose.app.yml logs -f

# Databases
db-up: ## Start databases
	docker-compose -f docker-compose.databases.yml up -d

db-down: ## Stop databases
	docker-compose -f docker-compose.databases.yml down

db-restart: ## Restart databases
	docker-compose -f docker-compose.databases.yml restart

# Jenkins
jenkins-up: ## Start Jenkins
	docker-compose -f docker-compose.jenkins.yml up -d

jenkins-down: ## Stop Jenkins
	docker-compose -f docker-compose.jenkins.yml down

# All services
all-up: db-up app-up jenkins-up ## Start tất cả services

all-down: app-down db-down jenkins-down ## Stop tất cả services

# Exec vào containers
exec-next: ## Vào nextjs container
	docker exec -it nextjs-app sh

exec-nest: ## Vào nestjs container
	docker exec -it nestjs-app sh

exec-pg: ## Vào postgres
	docker exec -it postgres psql -U postgres

exec-redis: ## Vào redis
	docker exec -it redis redis-cli

exec-mongo: ## Vào mongodb
	docker exec -it mongodb mongosh

# Status
status: ## Xem status containers
	docker ps -a

# Clean
clean: ## Xóa containers và volumes
	docker-compose -f docker-compose.app.yml down -v
	docker-compose -f docker-compose.databases.yml down -v
	docker-compose -f docker-compose.jenkins.yml down -v