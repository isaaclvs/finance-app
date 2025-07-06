# Docker Setup for Finance App

## Prerequisites
- Docker
- Docker Compose (V2)

## Getting Started

1. **Build and start the containers:**
   ```bash
   docker compose up --build
   ```

2. **Access the application:**
   - Rails app: http://localhost:3000
   - PostgreSQL: localhost:5433 (mapped to 5432 inside container)

## Common Commands

```bash
# Start containers
docker compose up

# Start in background
docker compose up -d

# Stop containers
docker compose down

# View logs
docker compose logs -f

# Run Rails console
docker compose exec web rails console

# Run migrations
docker compose exec web rails db:migrate

# Run tests
docker compose exec web rails test

# Access bash shell
docker compose exec web bash
```

## Database Management

The PostgreSQL database runs in a separate container:
- Host: db (within Docker network)
- Port: 5432 (internal) / 5433 (external)
- User: postgres
- Password: postgres
- Database: finance_app_development

## Volumes

- `postgres_data`: Persists PostgreSQL data
- `bundle_cache`: Caches Ruby gems
- `node_modules`: Caches Node modules

## Troubleshooting

If you encounter issues:

1. **Reset everything:**
   ```bash
   docker compose down -v
   docker compose up --build
   ```

2. **Check logs:**
   ```bash
   docker compose logs web
   docker compose logs db
   ```