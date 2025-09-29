# spec/factories/ratings.rb
FactoryBot.define do
  factory :rating do
    stars { 3 }
    association :movie
    association :user, factory: :tempest_user
  end
end
