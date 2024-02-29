FactoryBot.define do
  factory :movie do
    active { false }

    content_rating { 'g' }
    cover { 'MyString' }
    description { 'MyText' }
    released_on { '2024-02-29' }
    title { 'MyString' }
  end
end
