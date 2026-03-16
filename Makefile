# =============================================================================
# Makefile - SQL Server Docker commands
# =============================================================================

include .env
export

# Khởi động SQL Server và tự động chạy migrations
up:
	docker compose up -d sqlserver
	@echo "Doi SQL Server khoi dong..."
	docker compose up migrate

# Dừng tất cả containers
down:
	docker compose down

# Xóa hoàn toàn (kể cả data) - CẨNTHẬN: mất hết data!
reset:
	docker compose down -v
	docker compose up -d sqlserver
	@echo "Doi SQL Server khoi dong..."
	docker compose up migrate

# Chỉ chạy migrations (SQL Server phải đang chạy)
migrate:
	docker compose up migrate

# Xem logs của SQL Server
logs:
	docker compose logs -f sqlserver

# Mở SQL shell trong container
shell:
	docker exec -it sql_server_uit /opt/mssql-tools18/bin/sqlcmd \
		-S localhost -U sa -P "$(SQL_PASSWORD)" -C -d "$(DB_NAME)"

# Xem danh sách migrations đã chạy
history:
	docker exec -it sql_server_uit /opt/mssql-tools18/bin/sqlcmd \
		-S localhost -U sa -P "$(SQL_PASSWORD)" -C -d "$(DB_NAME)" \
		-Q "SELECT Id, FileName, AppliedAt FROM __migrations_history ORDER BY Id"

# Xem status containers
status:
	docker compose ps

.PHONY: up down reset migrate logs shell history status
