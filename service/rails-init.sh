#!/bin/bash
set -e

# データベースが準備できるまで待機
echo "Waiting for database..."
until bundle exec rails db:version > /dev/null 2>&1; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

# データベースが存在しない場合は作成
echo "Creating database if it does not exist..."
bundle exec rails db:create 2>/dev/null || true

# マイグレーションを実行
echo "Running database migrations..."
bundle exec rails db:migrate

# 本番環境でシードデータがある場合は実行
if [ "$RAILS_ENV" = "production" ] && [ -f "db/seeds.rb" ]; then
  echo "Running seed data..."
  bundle exec rails db:seed
fi

echo "Database initialization completed successfully!"

# Railsサーバーを起動
echo "Starting Rails server..."
exec bundle exec rails server -b 0.0.0.0
