FactoryBot.define do
  factory :movie_copy do
    active { false }
    copies { 1 }

    format { 'vhs' }
    movie_id { 1 }
    rental_price { 1 }
  end
end
