FactoryBot.define do
  factory :communication_record do
    body { 'MyText' }
    communication_recordable_id { 1 }
    communication_recordable_type { 'MyString' }
    from { 'MyString' }
    received_at { '2024-02-29 15:45:47' }
    sent_at { '2024-02-29 15:45:47' }
    subject { 'MyString' }
    to { 'MyString' }
  end
end
