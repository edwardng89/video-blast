FactoryBot.define do
  factory :communication_record do
    body { 'MyText' }
    communication_recordable_id { 1 }
    communication_recordable_type { 'MyString' }
    from { 'MyString' }
    received_at { '2024-02-29 15:16:36' }
    sent_at { '2024-02-29 15:16:36' }
    subject { 'MyString' }
    to { 'MyString' }
  end
end
