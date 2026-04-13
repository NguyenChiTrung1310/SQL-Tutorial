# =============================================================================
# Makefile - SQL Server Docker commands
# =============================================================================

include .env
export

# Khởi động SQL Server
up:
	docker compose up -d sqlserver

# Dừng containers
down:
	docker compose down

# Xóa hoàn toàn (kể cả data) - CẢNH BÁO: mất hết data!
reset:
	docker compose down -v

# Mở SQL shell (kết nối vào master, tự chọn database trong shell)
shell:
	docker exec -it sql_server_uit /opt/mssql-tools18/bin/sqlcmd \
		-S localhost -U sa -P "$(SQL_PASSWORD)" -C

# Xem logs của SQL Server
logs:
	docker compose logs -f sqlserver

# Xem status containers
status:
	docker compose ps

.PHONY: up down reset shell logs status
