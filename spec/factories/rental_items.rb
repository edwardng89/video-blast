FactoryBot.define do
  factory :rental_item do
    association :rental
    association :copy
    quantity { 1 }
  end
end
