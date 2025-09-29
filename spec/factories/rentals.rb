# spec/factories/rentals.rb
FactoryBot.define do
  factory :rental do
    association :user, factory: :tempest_user
    order_status { "ongoing" }
    rental_date  { Date.current }
    due_date     { Date.current + 7.days }

    trait :with_item do
      after(:create) do |rental|
        movie = create(:movie)
        copy  = create(:copy, movie:, rental_cost: 500, copy_format: "DVD")
        create(:rental_item, rental:, copy:, quantity: 1)
      end
    end
  end
end
