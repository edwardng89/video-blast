# spec/factories/actors.rb
FactoryBot.define do
  factory :actor do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
  end
end
