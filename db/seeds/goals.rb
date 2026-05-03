puts "Creating sample goals..."

user = User.find_by(email: SEED_USER_EMAIL)
return unless user

emergency_cat    = user.categories.find_by(name: "Health")
vacation_cat     = user.categories.find_by(name: "Entertainment")
housing_cat      = user.categories.find_by(name: "Housing")
food_cat         = user.categories.find_by(name: "Food")
freelance_cat    = user.categories.find_by(name: "Freelance")

goals_data = [
  # --- One-time goals ---
  {
    title:          "Emergency Fund",
    description:    "Build an emergency fund to cover 6 months of expenses",
    target_amount:  15_000,
    current_amount: 5_250,
    target_date:    14.months.from_now,
    goal_type:      "savings",
    status:         "active",
    category:       emergency_cat
  },
  {
    title:          "Europe Vacation",
    description:    "Save for a two-week vacation to Europe",
    target_amount:  8_000,
    current_amount: 3_200,
    target_date:    8.months.from_now,
    goal_type:      "savings",
    status:         "active",
    category:       vacation_cat
  },
  {
    title:          "Pay Off Credit Card",
    description:    "Eliminate all credit card debt",
    target_amount:  4_500,
    current_amount: 4_500,
    target_date:    Date.current,
    goal_type:      "debt_payoff",
    status:         "completed"
  },
  {
    title:          "Home Down Payment",
    description:    "Save for a down payment on an apartment",
    target_amount:  50_000,
    current_amount: 12_000,
    target_date:    3.years.from_now,
    goal_type:      "savings",
    status:         "paused",
    category:       housing_cat
  },

  # --- Recurring monthly goals ---
  {
    title:          "Monthly Food Budget",
    description:    "Keep food expenses under $500 per month",
    target_amount:  500,
    current_amount: 0,
    target_date:    Date.current.end_of_month,
    goal_type:      "expense_reduction",
    status:         "active",
    category:       food_cat,
    recurring:      true,
    period_start:   Date.current.beginning_of_month,
    period_end:     Date.current.end_of_month
  },
  {
    title:          "Monthly Freelance Revenue",
    description:    "Earn at least $1,000 from freelance work each month",
    target_amount:  1_000,
    current_amount: 0,
    target_date:    Date.current.end_of_month,
    goal_type:      "income_increase",
    status:         "active",
    category:       freelance_cat,
    recurring:      true,
    period_start:   Date.current.beginning_of_month,
    period_end:     Date.current.end_of_month
  }
]

goals_data.each do |attrs|
  goal = user.goals.find_or_initialize_by(title: attrs[:title])

  if goal.new_record?
    goal.description    = attrs[:description]
    goal.target_amount  = attrs[:target_amount]
    goal.current_amount = attrs[:current_amount]
    goal.target_date    = attrs[:target_date]
    goal.goal_type      = attrs[:goal_type]
    goal.status         = attrs[:status]
    goal.category       = attrs[:category]
    goal.recurring      = attrs[:recurring] || false
    goal.period_start   = attrs[:period_start]
    goal.period_end     = attrs[:period_end]
    goal.save!
    puts "  Goal created: #{goal.title}"
  else
    puts "  Goal skipped (exists): #{goal.title}"
  end
end

# Simulate one rolled-over cycle for the Monthly Food Budget goal
food_budget_goal = user.goals.find_by(title: "Monthly Food Budget")
if food_budget_goal && user.goals.where(title: "Monthly Food Budget", status: "rolled_over").none?
  prev_start = 1.month.ago.beginning_of_month
  prev_end   = 1.month.ago.end_of_month

  rolled = user.goals.new(
    title:          "Monthly Food Budget",
    description:    food_budget_goal.description,
    target_amount:  500,
    current_amount: 423,
    target_date:    prev_end,
    goal_type:      "expense_reduction",
    status:         "rolled_over",
    category:       food_cat,
    recurring:      true,
    period_start:   prev_start,
    period_end:     prev_end,
    parent_goal_id: food_budget_goal.id
  )
  rolled.save!(validate: false)
  puts "  Rolled-over cycle created for: Monthly Food Budget (#{prev_start.strftime('%b %Y')})"
end

puts "Total goals: #{user.goals.count}"
