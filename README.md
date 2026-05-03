# Finance App

> A modern personal finance management application built with Ruby on Rails 8, following 37signals patterns and conventions.

🌐 **Live Site**: [Personal Finance Tracker](https://finance-app-irov.onrender.com/)

[🎥 **Watch Demo Video**](https://drive.google.com/file/d/1AkaJr_SvZqhYPfp5agA1tad0IEmuOhR8/view?usp=sharing)

---

## Features

### Transactions
- Create, edit, and delete income and expense transactions
- Categorize with custom categories and color-coded tags
- Multi-filter: type, category, tag, date range, and text search
- Paginated list (20 per page) with mobile card layout
- CSV import with preview and per-row validation
- CSV export of filtered results

### Dashboard & Analytics
- Balance summary with current-month income, expenses, and net balance
- **Income vs Expenses** bar chart
- **Expenses by Category** pie chart
- **Monthly Evolution** line chart (last 6 months, income vs expenses)
- **Month-over-month comparison** with absolute and percentage changes
- **Category budget alerts** — warning at 80%, exceeded at 100%
- Filters applied to charts and transaction list simultaneously

### Goals
- Four goal types: Savings, Expense Reduction, Income Increase, Debt Payoff
- Five statuses: Active, Completed, Paused, Cancelled, Rolled Over
- Progress tracking with percentage and visual indicators
- Due-soon and overdue detection
- **Recurring monthly goals** — automatically roll over to a new cycle each month
- Cycle history view for rolled-over goals
- Filtering by type, status, and search

### Categories & Tags
- Custom categories with hex color coding and optional monthly budget limits
- Tags (many-to-many with transactions) with their own colors
- Prevent deletion of categories or tags that have associated transactions

### Background Jobs
- Goal due-soon email notifications (7-day window)
- Monthly financial summary emails
- Automatic rollover of recurring goals (via `rake goals:process_rollovers` or cron)
- Job monitoring dashboard at `/jobs/monitoring`

### User Experience
- Dark mode toggle
- Fully responsive — mobile-first with dedicated card layouts
- Real-time UI updates via Turbo Frames and Turbo Streams (no full-page reloads)
- i18n support: English and Brazilian Portuguese (pt-BR)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby 3.3.6 · Rails 8.1.1 |
| Database | PostgreSQL 16 |
| Frontend | Hotwire (Turbo + Stimulus) · TailwindCSS · Importmap |
| Charts | Chartkick |
| Authentication | Devise 5 |
| Pagination | Kaminari |
| Job Queue | Solid Queue |
| Caching | Solid Cache |
| WebSockets | Solid Cable |
| Deployment | Kamal · Docker · Thruster |
| Security | Brakeman |
| Code Quality | RuboCop (omakase) |
| Testing | RSpec · FactoryBot · Faker · Capybara · SimpleCov |

---

## Getting Started

### Prerequisites

- Docker & Docker Compose (recommended)
- Or: Ruby 3.3.6, PostgreSQL 16, Node.js 22

### Docker (Recommended)

```bash
# Start all services
docker compose up

# First time only — set up the database and seed demo data
docker compose exec web rails db:create db:migrate db:seed
```

App runs at **http://localhost:3000** — PostgreSQL is exposed on **localhost:5434**.

Demo credentials seeded by default:
- **Email**: `demo@example.com`
- **Password**: `password123`

### Local Development (without Docker)

```bash
# Install dependencies and set up the database
./bin/setup

# Start the development server
./bin/dev
```

App runs at **http://localhost:3000**.

---

## Common Commands

### Development

```bash
# Docker
docker compose up                            # Start services
docker compose exec web rails console        # Rails console
docker compose exec web rails db:migrate     # Run migrations
docker compose exec web rails db:seed        # Seed demo data

# Local
./bin/dev                                    # Start with live reload
rails console
rails db:migrate
rails db:seed
```

### Testing

```bash
# Docker
docker compose run --rm web bundle exec rspec

# Local
bundle exec rspec                            # Full suite
bundle exec rspec spec/models               # Models only
bundle exec rspec spec/requests             # Request/integration specs
bundle exec rspec spec/jobs                 # Job specs
```

### Code Quality

```bash
bundle exec rubocop                          # Linting
bundle exec brakeman                         # Security audit
```

### Rake Tasks

```bash
# Process recurring goal rollovers (run monthly via cron)
rails goals:process_rollovers
```

### Deployment

```bash
kamal setup    # Initial setup
kamal deploy   # Deploy to production
```

---

## Project Structure

```
app/
├── controllers/
│   ├── dashboard_controller.rb        # Charts, budget alerts, goals stats
│   ├── transactions_controller.rb     # CRUD + filtering + CSV export
│   ├── goals_controller.rb            # CRUD + progress update + history
│   ├── categories_controller.rb
│   ├── tags_controller.rb
│   ├── transaction_imports_controller.rb  # CSV import preview workflow
│   └── jobs_controller.rb             # Job monitoring
├── models/
│   ├── user.rb                        # Auth + balance helpers
│   ├── transaction.rb                 # income/expense with tags
│   ├── category.rb                    # Colors + budget limits
│   ├── tag.rb                         # Many-to-many with transactions
│   ├── goal.rb                        # Progress + rollover logic
│   ├── transaction_tagging.rb
│   └── concerns/
│       └── progressable.rb            # Shared progress tracking
├── services/
│   ├── dashboard/
│   │   ├── charts_data.rb
│   │   ├── monthly_evolution_data.rb
│   │   ├── month_comparison_data.rb
│   │   ├── category_budget_alerts.rb
│   │   └── transactions_filter.rb
│   ├── import/
│   │   ├── transactions_csv_parser.rb
│   │   ├── transactions_preview.rb
│   │   └── transactions_importer.rb
│   ├── export/
│   │   └── transactions_csv.rb
│   └── reports/
│       └── monthly_summary.rb
├── jobs/
│   ├── process_goal_rollovers_job.rb
│   ├── enqueue_goal_due_soon_notifications_job.rb
│   ├── goal_due_soon_notification_job.rb
│   ├── enqueue_monthly_financial_reports_job.rb
│   └── monthly_financial_report_job.rb
├── mailers/
│   ├── goal_notifications_mailer.rb
│   └── reports_mailer.rb
└── javascript/controllers/            # Stimulus controllers
db/
├── seeds.rb                           # Orchestrates all seed files
└── seeds/
    ├── tags.rb                        # Sample tags
    ├── transactions.rb                # 6 months of historical transactions with tags
    └── goals.rb                       # One-time + recurring + rolled-over goals
lib/tasks/
└── goals.rake                         # goals:process_rollovers
spec/
├── factories/
├── models/
├── requests/
├── services/
├── jobs/
└── features/                          # Capybara system tests
```

---

## Database Schema (key tables)

| Table | Key columns |
|---|---|
| `users` | email, encrypted_password (Devise) |
| `categories` | name, color, monthly_budget_limit |
| `tags` | name, color |
| `transactions` | amount, date, description, transaction_type (income/expense), category_id |
| `transaction_taggings` | transaction_id, tag_id |
| `goals` | title, target_amount, current_amount, target_date, goal_type, status, recurring, period_start, period_end, parent_goal_id |

---

## Contributing

1. Follow the conventions in `CLAUDE.md`
2. Write tests for every new feature
3. Run `rspec` and `rubocop` before opening a PR
4. Use descriptive commit messages scoped to the change

---

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).
