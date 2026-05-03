puts "Creating sample transactions..."

user = User.find_by(email: SEED_USER_EMAIL)
return unless user

# Categories
salary_cat       = user.categories.find_by(name: "Salary")
freelance_cat    = user.categories.find_by(name: "Freelance")
investments_cat  = user.categories.find_by(name: "Investments")
food_cat         = user.categories.find_by(name: "Food")
transport_cat    = user.categories.find_by(name: "Transport")
housing_cat      = user.categories.find_by(name: "Housing")
entertainment_cat = user.categories.find_by(name: "Entertainment")
health_cat       = user.categories.find_by(name: "Health")
education_cat    = user.categories.find_by(name: "Education")
shopping_cat     = user.categories.find_by(name: "Shopping")
bills_cat        = user.categories.find_by(name: "Bills")

# Tags
essential_tag    = user.tags.find_by(name: "Essential")
leisure_tag      = user.tags.find_by(name: "Leisure")
work_tag         = user.tags.find_by(name: "Work")
health_tag       = user.tags.find_by(name: "Health")
family_tag       = user.tags.find_by(name: "Family")
subscription_tag = user.tags.find_by(name: "Subscription")
one_time_tag     = user.tags.find_by(name: "One-time")
recurring_tag    = user.tags.find_by(name: "Recurring")

# Helper to tag a transaction idempotently
def tag_transaction(transaction, *tags)
  tags.compact.each do |tag|
    next if transaction.tags.exists?(id: tag.id)
    transaction.tags << tag
  end
end

# Build transactions spread across the last 6 months
transactions_data = []

6.downto(1) do |months_ago|
  bom = months_ago.months.ago.beginning_of_month

  transactions_data << {
    amount: 5500, type: "income", date: bom,
    description: "Monthly salary", category: salary_cat,
    tags: [ essential_tag, recurring_tag, work_tag ]
  }

  transactions_data << {
    amount: 350, type: "income", date: bom + 10.days,
    description: "Dividend income", category: investments_cat,
    tags: [ recurring_tag ]
  }

  transactions_data << {
    amount: 1200, type: "expense", date: bom + 1.day,
    description: "Rent payment", category: housing_cat,
    tags: [ essential_tag, recurring_tag ]
  }

  transactions_data << {
    amount: 89.90, type: "expense", date: bom + 2.days,
    description: "Internet & phone bill", category: bills_cat,
    tags: [ essential_tag, subscription_tag, recurring_tag ]
  }

  transactions_data << {
    amount: 45.00, type: "expense", date: bom + 3.days,
    description: "Streaming services", category: entertainment_cat,
    tags: [ subscription_tag, recurring_tag, leisure_tag ]
  }

  transactions_data << {
    amount: rand(280..380).to_f, type: "expense", date: bom + 5.days,
    description: "Supermarket groceries", category: food_cat,
    tags: [ essential_tag, recurring_tag ]
  }

  transactions_data << {
    amount: rand(60..120).to_f, type: "expense", date: bom + 8.days,
    description: "Fuel & transport", category: transport_cat,
    tags: [ essential_tag, recurring_tag ]
  }
end

# Current month additions
today = Date.current
bom   = today.beginning_of_month

transactions_data << {
  amount: 5500, type: "income", date: bom,
  description: "Monthly salary", category: salary_cat,
  tags: [ essential_tag, recurring_tag, work_tag ]
}

transactions_data << {
  amount: 1200, type: "expense", date: bom + 1.day,
  description: "Rent payment", category: housing_cat,
  tags: [ essential_tag, recurring_tag ]
}

transactions_data << {
  amount: 89.90, type: "expense", date: bom + 2.days,
  description: "Internet & phone bill", category: bills_cat,
  tags: [ essential_tag, subscription_tag, recurring_tag ]
}

transactions_data << {
  amount: 350, type: "income", date: bom + 3.days,
  description: "Dividend income", category: investments_cat,
  tags: [ recurring_tag ]
}

transactions_data << {
  amount: 45.00, type: "expense", date: bom + 4.days,
  description: "Streaming services", category: entertainment_cat,
  tags: [ subscription_tag, recurring_tag, leisure_tag ]
}

transactions_data << {
  amount: 800, type: "income", date: today - 5.days,
  description: "Freelance web project", category: freelance_cat,
  tags: [ work_tag, one_time_tag ]
}

transactions_data << {
  amount: 47.50, type: "expense", date: today - 4.days,
  description: "Lunch at restaurant", category: food_cat,
  tags: [ leisure_tag ]
}

transactions_data << {
  amount: 120.00, type: "expense", date: today - 4.days,
  description: "Weekly groceries", category: food_cat,
  tags: [ essential_tag ]
}

transactions_data << {
  amount: 25.00, type: "expense", date: today - 3.days,
  description: "Bus & metro pass", category: transport_cat,
  tags: [ essential_tag, recurring_tag ]
}

transactions_data << {
  amount: 199.99, type: "expense", date: today - 3.days,
  description: "New sneakers", category: shopping_cat,
  tags: [ one_time_tag, leisure_tag ]
}

transactions_data << {
  amount: 85.00, type: "expense", date: today - 2.days,
  description: "Doctor consultation", category: health_cat,
  tags: [ health_tag, essential_tag ]
}

transactions_data << {
  amount: 149.00, type: "expense", date: today - 2.days,
  description: "Online course subscription", category: education_cat,
  tags: [ subscription_tag, work_tag ]
}

transactions_data << {
  amount: 320.00, type: "income", date: today - 1.day,
  description: "Freelance design work", category: freelance_cat,
  tags: [ work_tag ]
}

transactions_data << {
  amount: 65.00, type: "expense", date: today - 1.day,
  description: "Family dinner", category: food_cat,
  tags: [ family_tag, leisure_tag ]
}

transactions_data << {
  amount: 50.00, type: "expense", date: today,
  description: "Gym membership", category: health_cat,
  tags: [ health_tag, subscription_tag, recurring_tag ]
}

created = 0
skipped = 0

transactions_data.each do |attrs|
  transaction = user.transactions.find_or_initialize_by(
    description: attrs[:description],
    date:        attrs[:date]
  )

  if transaction.new_record?
    transaction.amount           = attrs[:amount]
    transaction.transaction_type = attrs[:type]
    transaction.category         = attrs[:category]
    transaction.save!
    tag_transaction(transaction, *attrs[:tags])
    created += 1
  else
    skipped += 1
  end
end

puts "  Created: #{created} | Skipped (already exist): #{skipped}"
puts "  Total transactions: #{user.transactions.count}"
puts "  Total income:  #{user.transactions.income.sum(:amount)}"
puts "  Total expenses: #{user.transactions.expense.sum(:amount)}"
