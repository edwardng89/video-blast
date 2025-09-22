class CreateRentals < ActiveRecord::Migration[7.1]
  def change
    create_table :rentals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :copy, null: false, foreign_key: true

      t.string :order_number, null: false
      t.date   :rental_date, null: false
      t.date   :due_date
      t.date   :return_date
      t.string :order_status, default: "ongoing"
      t.timestamps
    end
    add_index :rentals, :order_number, unique: true
  end
end
