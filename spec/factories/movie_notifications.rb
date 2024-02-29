FactoryBot.define do
  factory :movie_notification do
    canceled_on { '2024-02-29' }
    movie_copy_id { 1 }
    requested_on { '2024-02-29' }
    user_id { 1 }
  end
end
