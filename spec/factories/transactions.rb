FactoryBot.define do
  factory :transaction do
    amount { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    transaction_type { %w[income expense].sample }
    date { Faker::Date.between(from: 30.days.ago, to: Date.current) }
    description { Faker::Lorem.sentence }
    association :user
    association :category

    trait :income do
      transaction_type { "income" }
    end

    trait :expense do
      transaction_type { "expense" }
    end
  end
end
