FactoryBot.define do
  factory :genre do
    active { false }
    name { 'MyString' }
    sort_order { 1 }
  end
end
