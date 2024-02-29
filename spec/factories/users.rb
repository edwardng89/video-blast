FactoryBot.define do
  factory :user do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    password { '*Azhwaagkb12142521' }
    active { false }
    address_line_1 { 'MyString' }
    address_line_2 { 'MyString' }
    admin { false }
    first_name { 'MyString' }

    gender { 'male' }
    last_name { 'MyString' }
    postcode { 'MyString' }
    role { 'super_user' }

    state { 'act' }
    suburb { 'MyString' }
  end
end
