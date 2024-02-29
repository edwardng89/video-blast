FactoryBot.define do
  factory :movie_actor do
    actor_id { 1 }
    movie_id { 1 }
    sort_order { 1 }
  end
end
