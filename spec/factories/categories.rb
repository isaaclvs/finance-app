FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department }
    color { "##{Faker::Color.hex_color[1..]}" }
    monthly_budget_limit { nil }
    association :user
  end
end
