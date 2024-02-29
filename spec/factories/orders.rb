FactoryBot.define do
  factory :order do
    return_due { '2024-02-29' }

    status { 'awaiting_customer' }
    user_id { 1 }
  end
end
