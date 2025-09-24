class AddQuantityToRentalItems < ActiveRecord::Migration[7.1]
  def change
    add_column :rental_items, :quantity, :integer
  end
end
