#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
echo "Installing dependencies..."
bundle install

# Install Node.js dependencies if they exist
if [ -f "package.json" ]; then
  echo "Installing Node.js dependencies..."
  npm install
fi

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile

# Clean up
echo "Cleaning up..."
bundle exec rails assets:clean

# Compile TailwindCSS
echo "Building TailwindCSS..."
bundle exec rails tailwindcss:build

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:migrate

echo "Build completed successfully!"