puts "Creating sample transactions..."

user = User.find_by(email: SEED_USER_EMAIL)
return unless user

# Get categories
salary_category = user.categories.find_by(name: 'Salary')
food_category = user.categories.find_by(name: 'Food')
transport_category = user.categories.find_by(name: 'Transport')
shopping_category = user.categories.find_by(name: 'Shopping')
bills_category = user.categories.find_by(name: 'Bills')
freelance_category = user.categories.find_by(name: 'Freelance')

transactions_data = [
  {
    amount: 5000,
    transaction_type: "income",
    date: Date.current.beginning_of_month,
    description: "Monthly salary",
    category: salary_category
  },
  {
    amount: 800,
    transaction_type: "income",
    date: Date.current - 5.days,
    description: "Freelance project payment",
    category: freelance_category
  },
  {
    amount: 45.50,
    transaction_type: "expense",
    date: Date.current - 1.day,
    description: "Lunch at restaurant",
    category: food_category
  },
  {
    amount: 25.00,
    transaction_type: "expense",
    date: Date.current - 2.days,
    description: "Uber ride to work",
    category: transport_category
  },
  {
    amount: 150.00,
    transaction_type: "expense",
    date: Date.current - 3.days,
    description: "New shoes",
    category: shopping_category
  },
  {
    amount: 89.99,
    transaction_type: "expense",
    date: Date.current - 4.days,
    description: "Internet bill",
    category: bills_category
  },
  {
    amount: 120.00,
    transaction_type: "expense",
    date: Date.current - 7.days,
    description: "Groceries",
    category: food_category
  }
]

transactions_data.each do |transaction_attrs|
  user.transactions.find_or_create_by!(
    description: transaction_attrs[:description],
    date: transaction_attrs[:date]
  ) do |transaction|
    transaction.amount = transaction_attrs[:amount]
    transaction.transaction_type = transaction_attrs[:transaction_type]
    transaction.category = transaction_attrs[:category]
  end
end

puts "Created #{user.transactions.count} sample transactions!"
puts "Total income: #{user.transactions.income.sum(:amount)}"
puts "Total expenses: #{user.transactions.expense.sum(:amount)}"
puts "Balance: #{user.transactions.balance}"
