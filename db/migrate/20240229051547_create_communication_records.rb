class CreateCommunicationRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :communication_records do |t|
      t.userstamps
      t.datetime :deleted_at
      t.text :body
      t.integer :communication_recordable_id
      t.string :communication_recordable_type
      t.string :from
      t.datetime :received_at
      t.datetime :sent_at
      t.string :subject
      t.string :to

      t.timestamps
    end
  end
end
