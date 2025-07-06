#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Check if database exists
if ! PGPASSWORD=$POSTGRES_PASSWORD psql -h db -U postgres -lqt | cut -d \| -f 1 | grep -qw finance_app_development; then
  echo "Database does not exist. Creating..."
  bundle exec rails db:create
fi

# Run migrations
echo "Running database migrations..."
bundle exec rails db:migrate

# Seed the database if needed
if [ "$RAILS_ENV" = "development" ]; then
  echo "Seeding database..."
  bundle exec rails db:seed
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"