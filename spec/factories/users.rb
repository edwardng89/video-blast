FactoryBot.define do
  # Do NOT name this :user if you already have another User factory.
  factory :tempest_user, class: 'Tempest::User' do
    sequence(:email) { |n| "person#{n}@example.com" }
    
    # Required on create
    first_name { 'Jane' }
    last_name  { 'Doe' }
    role       { 'user' }          # valid enum: "user" | "admin" | "super_admin"

    # Optional but valid
    gender         { nil }         # or "male"/"female"/"other"
    state          { 'SA' }        # must be one of: SA NSW VIC QLD WA TAS NT ACT (uppercase)
    postcode       { '5000' }      # must be 4 digits
    suburb         { 'MySuburb' }
    address_line_1 { '123 Test St' }
    address_line_2 { nil }

    # If these columns exist in your DB you can keep them; otherwise remove:
    # active { false }

    trait :admin do
      role { 'admin' }
    end

    trait :super_admin do
      role { 'super_admin' }
    end

    trait :with_optional_blank do
      state    { nil }
      postcode { nil }
      suburb   { nil }
    end
  end
end
