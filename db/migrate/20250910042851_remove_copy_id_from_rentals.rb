class RemoveCopyIdFromRentals < ActiveRecord::Migration[7.1]
  def change
    remove_column :rentals, :copy_id, :bigint
  end
end
