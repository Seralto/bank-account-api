FactoryBot.define do
  factory :account do
    client
    balance { Faker::Number.decimal(5, 2) }
  end
end
