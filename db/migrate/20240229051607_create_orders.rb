class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.userstamps
      t.datetime :deleted_at
      t.date :return_due
      t.string :status
      t.integer :user_id

      t.timestamps
    end
    add_index :orders, :user_id
  end
end
