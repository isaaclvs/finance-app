FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department }
    color { "##{Faker::Color.hex_color[1..]}" }
    association :user
  end
end
