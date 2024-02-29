FactoryBot.define do
  factory :order_movie_copy do
    movie_copy_id { 1 }
    order_id { 1 }
    returned_on { '2024-02-29' }
  end
end
