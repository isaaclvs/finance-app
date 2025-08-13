FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_transactions do
      after(:create) do |user|
        income_category = create(:category, user: user, name: "Salary")
        expense_category = create(:category, user: user, name: "Food")

        create_list(:transaction, 3, :income, user: user, category: income_category)
        create_list(:transaction, 2, :expense, user: user, category: expense_category)
      end
    end

    trait :with_goals do
      after(:create) do |user|
        create_list(:goal, 2, user: user)
      end
    end

    trait :with_complete_data do
      after(:create) do |user|
        income_category = create(:category, user: user, name: "Salary")
        expense_category = create(:category, user: user, name: "Food")

        # Create transactions from different months for testing
        create(:transaction, :income, user: user, category: income_category, amount: 1000, date: Date.current)
        create(:transaction, :expense, user: user, category: expense_category, amount: 200, date: Date.current)
        create(:transaction, :income, user: user, category: income_category, amount: 800, date: 1.month.ago)

        # Create goals
        create(:goal, user: user, category: income_category)
        create(:goal, user: user, status: "completed", current_amount: 500, target_amount: 500)
      end
    end
  end
end
