FactoryBot.define do
  factory :movie do
    title          { "Example Movie" }
    description    { "A really great movie description." }
    content_rating { "PG" }
    released_on    { Date.today }
    active         { true }
  end
end
