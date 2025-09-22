class AddInventoryFieldsToCopies < ActiveRecord::Migration[7.1]
  def change
    add_column :copies, :no_of_copies, :integer
    add_column :copies, :active, :boolean
    add_column :copies, :rental_cost, :integer
    add_column :copies, :deleted_at, :datetime

  end
end
