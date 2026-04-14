FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.unique.word }
    color { "##{Faker::Color.hex_color[1..]}" }
    association :user
  end
end