# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default categories for development/demo user
if Rails.env.development?
  # Find or create a demo user
  demo_user = User.find_or_create_by!(email: "demo@example.com") do |user|
    user.password = "password123"
  end

  # Ensure password is always set correctly
  unless demo_user.valid_password?("password123")
    demo_user.update!(password: "password123")
  end

  puts "Demo user created: #{demo_user.email}"

  # Create default categories with colors
  Category::DEFAULT_COLORS.each do |name, color|
    category = demo_user.categories.find_or_create_by!(name: name) do |cat|
      cat.color = color
    end
    puts "Category created: #{category.name} (#{category.color})"
  end

  puts "\nSeeding completed!"
  puts "Demo user credentials: demo@example.com / password123"
  puts "Total categories created: #{demo_user.categories.count}"

  # Load transaction seeds
  load Rails.root.join('db/seeds/transactions.rb')

  # Create sample goals
  emergency_category = demo_user.categories.find_by(name: 'Emergency Fund')
  vacation_category = demo_user.categories.find_by(name: 'Entertainment')

  goals_data = [
    {
      title: 'Emergency Fund',
      description: 'Build an emergency fund to cover 6 months of expenses',
      target_amount: 15000,
      current_amount: 3750,
      target_date: 18.months.from_now,
      goal_type: 'savings',
      status: 'active',
      category: emergency_category
    },
    {
      title: 'Annual Vacation',
      description: 'Save for a two-week vacation to Europe',
      target_amount: 8000,
      current_amount: 2400,
      target_date: 10.months.from_now,
      goal_type: 'savings',
      status: 'active',
      category: vacation_category
    },
    {
      title: 'Reduce Dining Out',
      description: 'Cut dining expenses by cooking more meals at home',
      target_amount: 2400, # Reduce by $200/month over 12 months
      current_amount: 800,  # Already saved $800
      target_date: 8.months.from_now,
      goal_type: 'expense_reduction',
      status: 'active'
    },
    {
      title: 'Side Hustle Income',
      description: 'Increase monthly income through freelance work',
      target_amount: 6000, # $500/month extra for 12 months
      current_amount: 1500, # Made $1500 so far
      target_date: 9.months.from_now,
      goal_type: 'income_increase',
      status: 'active'
    },
    {
      title: 'Pay Off Credit Card',
      description: 'Eliminate all credit card debt',
      target_amount: 4500,
      current_amount: 4500,
      target_date: Date.current,
      goal_type: 'debt_payoff',
      status: 'completed'
    }
  ]

  goals_data.each do |goal_attrs|
    goal = demo_user.goals.find_or_create_by!(title: goal_attrs[:title]) do |g|
      g.description = goal_attrs[:description]
      g.target_amount = goal_attrs[:target_amount]
      g.current_amount = goal_attrs[:current_amount]
      g.target_date = goal_attrs[:target_date]
      g.goal_type = goal_attrs[:goal_type]
      g.status = goal_attrs[:status]
      g.category = goal_attrs[:category]
    end
    puts "Goal created: #{goal.title} (#{goal.progress_percentage}% complete)"
  end

  puts "Total goals created: #{demo_user.goals.count}"
end
