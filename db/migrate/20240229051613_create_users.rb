class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.userstamps
      t.datetime :deleted_at
      t.boolean :active
      t.string :address_line_1
      t.string :address_line_2
      t.boolean :admin
      t.string :first_name
      t.string :gender
      t.string :last_name
      t.string :postcode
      t.string :role
      t.string :state
      t.string :suburb

      t.timestamps
    end
  end
end
