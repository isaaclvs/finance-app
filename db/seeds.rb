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
end
