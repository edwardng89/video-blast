class CreateRentalItems < ActiveRecord::Migration[7.1]
  def change
    create_table :rental_items do |t|
      t.references :rental, null: false, foreign_key: true
      t.references :copy, null: false, foreign_key: true

      t.timestamps
    end

    add_index :rental_items, [:rental_id, :copy_id], unique: true
  end
end
