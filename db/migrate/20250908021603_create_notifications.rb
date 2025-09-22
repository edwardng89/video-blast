class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.string  :format
      t.boolean :fulfilled, default: false
      t.datetime :notified_at
      t.timestamps
    end
  end
end
