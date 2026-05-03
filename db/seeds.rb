# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

SEED_USER_EMAIL    = ENV.fetch("SEED_USER_EMAIL", "demo@example.com")
SEED_USER_PASSWORD = ENV.fetch("SEED_USER_PASSWORD", "password123")

unless Rails.env.production?
  # ── User ────────────────────────────────────────────────────────────────────
  demo_user = User.find_or_initialize_by(email: SEED_USER_EMAIL)
  demo_user.password              = SEED_USER_PASSWORD
  demo_user.password_confirmation = SEED_USER_PASSWORD
  demo_user.save!
  puts "Seed user ready: #{demo_user.email}"

  # ── Categories (with budget limits on expense categories) ───────────────────
  budget_limits = {
    "Food"          => 500,
    "Transport"     => 200,
    "Entertainment" => 150,
    "Shopping"      => 300,
    "Bills"         => 200,
    "Health"        => 250
  }

  Category::DEFAULT_COLORS.each do |name, color|
    category = demo_user.categories.find_or_initialize_by(name: name)
    if category.new_record?
      category.color               = color
      category.monthly_budget_limit = budget_limits[name]
      category.save!
      puts "  Category created: #{name}"
    else
      # Update budget limits on existing categories if not yet set
      if budget_limits[name] && category.monthly_budget_limit.nil?
        category.update!(monthly_budget_limit: budget_limits[name])
        puts "  Category updated (budget limit): #{name}"
      else
        puts "  Category skipped (exists): #{name}"
      end
    end
  end

  # ── Tags ────────────────────────────────────────────────────────────────────
  load Rails.root.join("db/seeds/tags.rb")

  # ── Transactions (6 months of history + current month, with tags) ───────────
  load Rails.root.join("db/seeds/transactions.rb")

  # ── Goals (one-time + recurring + rolled-over history) ──────────────────────
  load Rails.root.join("db/seeds/goals.rb")

  puts "\nSeeding complete!"
  puts "  Login: #{SEED_USER_EMAIL} / #{SEED_USER_PASSWORD}"
  puts "  Categories: #{demo_user.categories.count}"
  puts "  Tags:        #{demo_user.tags.count}"
  puts "  Transactions: #{demo_user.transactions.count}"
  puts "  Goals:        #{demo_user.goals.count}"
end
