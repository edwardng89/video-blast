FactoryBot.define do
  factory :tempest_user, class: "Tempest::User" do
    sequence(:email) { |n| "person#{n}@example.com" }
    first_name { "Jane" }
    last_name  { "Doe" }
    role       { "user" }

    # optional attributes
    gender         { nil }
    state          { "SA" }
    postcode       { "5000" }
    suburb         { "MySuburb" }
    address_line_1 { "123 Test St" }
    address_line_2 { nil }

    trait :admin do
      role { "admin" }
    end

    trait :super_admin do
      role { "super_admin" }
    end
  end
end
