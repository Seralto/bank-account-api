FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'top-secret' }
    password_confirmation { 'top-secret' }
  end
end
