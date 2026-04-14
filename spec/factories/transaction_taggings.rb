FactoryBot.define do
  factory :transaction_tagging do
    association :transaction_record, factory: :transaction
    association :tag
  end
end