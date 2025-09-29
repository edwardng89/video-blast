# spec/factories/copies.rb
FactoryBot.define do
  factory :copy do
    association :movie
    copy_format   { "DVD" }
    no_of_copies  { 3 }
    rental_cost   { 500 } # cents ($5.00)
  end
end
