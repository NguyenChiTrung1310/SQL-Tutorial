#!/bin/bash
# =============================================================================
# run_migrations.sh
# Script tự động chạy các migration SQL theo thứ tự
# Theo dõi migration nào đã chạy qua bảng __migrations_history
# =============================================================================

set -e

SQL_HOST="${SQL_HOST:-localhost}"
SQL_PASSWORD="${SQL_PASSWORD}"
DB_NAME="${DB_NAME:-sql_tutorial}"
SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
MIGRATIONS_DIR="/scripts/migrations"
SEEDS_DIR="/scripts/seeds"

# Hàm chạy sqlcmd
run_sql() {
  local query="$1"
  $SQLCMD -S "$SQL_HOST" -U sa -P "$SQL_PASSWORD" -C -Q "$query" -b
}

run_sql_file() {
  local file="$1"
  local db="$2"
  if [ -n "$db" ]; then
    $SQLCMD -S "$SQL_HOST" -U sa -P "$SQL_PASSWORD" -C -d "$db" -i "$file" -b
  else
    $SQLCMD -S "$SQL_HOST" -U sa -P "$SQL_PASSWORD" -C -i "$file" -b
  fi
}

echo "======================================"
echo "  SQL Server Migration Runner"
echo "======================================"

# 1. Tạo database nếu chưa tồn tại
echo "[1/4] Khởi tạo database: $DB_NAME..."
run_sql "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$DB_NAME') BEGIN CREATE DATABASE [$DB_NAME] END"

# 2. Tạo bảng theo dõi migration history
echo "[2/4] Khởi tạo bảng theo dõi migration..."
run_sql "
USE [$DB_NAME];
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = '__migrations_history')
BEGIN
  CREATE TABLE [dbo].[__migrations_history] (
    [Id]          INT           IDENTITY(1,1) PRIMARY KEY,
    [FileName]    NVARCHAR(255) NOT NULL UNIQUE,
    [AppliedAt]   DATETIME2     NOT NULL DEFAULT GETDATE(),
    [Checksum]    NVARCHAR(64)  NULL
  )
  PRINT 'Tao bang __migrations_history thanh cong'
END
"

# 3. Chạy migration files theo thứ tự
echo "[3/4] Chạy migrations từ: $MIGRATIONS_DIR"

if [ -d "$MIGRATIONS_DIR" ] && [ "$(ls -A $MIGRATIONS_DIR/*.sql 2>/dev/null)" ]; then
  for migration_file in $(ls "$MIGRATIONS_DIR"/*.sql | sort); do
    filename=$(basename "$migration_file")

    # Kiểm tra xem migration đã chạy chưa
    already_run=$($SQLCMD -S "$SQL_HOST" -U sa -P "$SQL_PASSWORD" -C -d "$DB_NAME" \
      -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM [__migrations_history] WHERE [FileName] = '$filename'" \
      -h -1 2>/dev/null | tr -d ' \r\n')

    if [ "$already_run" = "1" ]; then
      echo "  [SKIP] $filename (đã chạy)"
    else
      echo "  [RUN ] $filename ..."
      if run_sql_file "$migration_file" "$DB_NAME"; then
        # Ghi nhận migration đã chạy thành công
        run_sql "USE [$DB_NAME]; INSERT INTO [__migrations_history] ([FileName]) VALUES ('$filename')"
        echo "  [OK  ] $filename"
      else
        echo "  [FAIL] $filename - Dừng migration!"
        exit 1
      fi
    fi
  done
else
  echo "  Chưa có file migration nào."
fi

# 4. Chạy seed files nếu có
echo "[4/4] Chạy seed data từ: $SEEDS_DIR"

if [ -d "$SEEDS_DIR" ] && [ "$(ls -A $SEEDS_DIR/*.sql 2>/dev/null)" ]; then
  for seed_file in $(ls "$SEEDS_DIR"/*.sql | sort); do
    filename=$(basename "$seed_file")
    seed_key="seed:$filename"

    already_run=$($SQLCMD -S "$SQL_HOST" -U sa -P "$SQL_PASSWORD" -C -d "$DB_NAME" \
      -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM [__migrations_history] WHERE [FileName] = '$seed_key'" \
      -h -1 2>/dev/null | tr -d ' \r\n')

    if [ "$already_run" = "1" ]; then
      echo "  [SKIP] $filename (đã chạy)"
    else
      echo "  [RUN ] $filename ..."
      if run_sql_file "$seed_file" "$DB_NAME"; then
        run_sql "USE [$DB_NAME]; INSERT INTO [__migrations_history] ([FileName]) VALUES ('$seed_key')"
        echo "  [OK  ] $filename"
      else
        echo "  [FAIL] $filename - Dừng seed!"
        exit 1
      fi
    fi
  done
else
  echo "  Chưa có file seed nào."
fi

echo ""
echo "======================================"
echo "  Migration hoàn tất!"
echo "======================================"
