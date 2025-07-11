#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /rails/tmp/pids/server.pid

# Install any missing gems
echo "Installing gems..."
bundle install

# Ensure database exists and is migrated
echo "Preparing database..."
bundle exec rails db:prepare

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"