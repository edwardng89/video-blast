# spec/factories/genres.rb
FactoryBot.define do
  factory :genre do
    name   { Faker::Book.genre }
    active { true }
  end
end
