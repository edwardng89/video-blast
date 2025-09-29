# spec/factories/notifications.rb
FactoryBot.define do
  factory :notification do
    association :user, factory: :tempest_user
    association :movie
    format      { "DVD" }
    fulfilled   { false }
    notified_at { nil }
  end
end
