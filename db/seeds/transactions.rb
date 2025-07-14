puts "Creating sample transactions..."

user = User.find_by(email: 'demo@example.com')
return unless user

# Get categories
salary_category = user.categories.find_by(name: 'Salary')
food_category = user.categories.find_by(name: 'Food')
transport_category = user.categories.find_by(name: 'Transport')
shopping_category = user.categories.find_by(name: 'Shopping')
bills_category = user.categories.find_by(name: 'Bills')
freelance_category = user.categories.find_by(name: 'Freelance')

# Create income transactions
user.transactions.create!(
  amount: 5000,
  transaction_type: 'income',
  date: Date.current.beginning_of_month,
  description: 'Monthly salary',
  category: salary_category
)

user.transactions.create!(
  amount: 800,
  transaction_type: 'income',
  date: Date.current - 5.days,
  description: 'Freelance project payment',
  category: freelance_category
)

# Create expense transactions
user.transactions.create!(
  amount: 45.50,
  transaction_type: 'expense',
  date: Date.current - 1.day,
  description: 'Lunch at restaurant',
  category: food_category
)

user.transactions.create!(
  amount: 25.00,
  transaction_type: 'expense',
  date: Date.current - 2.days,
  description: 'Uber ride to work',
  category: transport_category
)

user.transactions.create!(
  amount: 150.00,
  transaction_type: 'expense',
  date: Date.current - 3.days,
  description: 'New shoes',
  category: shopping_category
)

user.transactions.create!(
  amount: 89.99,
  transaction_type: 'expense',
  date: Date.current - 4.days,
  description: 'Internet bill',
  category: bills_category
)

user.transactions.create!(
  amount: 120.00,
  transaction_type: 'expense',
  date: Date.current - 7.days,
  description: 'Groceries',
  category: food_category
)

puts "Created #{user.transactions.count} sample transactions!"
puts "Total income: $#{user.transactions.income.sum(:amount)}"
puts "Total expenses: $#{user.transactions.expense.sum(:amount)}"
puts "Balance: $#{user.transactions.balance}"
