FactoryBot.define do
  factory :goal do
    title { "Emergency Fund" }
    description { "Build an emergency fund to cover 6 months of expenses" }
    target_amount { 10000.0 }
    current_amount { 0.0 }
    target_date { 1.year.from_now }
    goal_type { "savings" }
    status { "active" }
    association :user
    association :category

    trait :savings do
      title { "Savings Goal" }
      goal_type { "savings" }
    end

    trait :expense_reduction do
      title { "Reduce Expenses" }
      goal_type { "expense_reduction" }
    end

    trait :income_increase do
      title { "Increase Income" }
      goal_type { "income_increase" }
    end

    trait :debt_payoff do
      title { "Pay Off Debt" }
      goal_type { "debt_payoff" }
    end

    trait :completed do
      status { "completed" }
      current_amount { target_amount }
    end

    trait :paused do
      status { "paused" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :overdue do
      target_date { 1.month.ago }
      status { "active" }
    end

    trait :due_soon do
      target_date { 3.days.from_now }
      status { "active" }
    end

    trait :in_progress do
      current_amount { target_amount * 0.5 }
    end

    trait :nearly_complete do
      current_amount { target_amount * 0.95 }
    end

    trait :without_category do
      category { nil }
    end
  end
end
