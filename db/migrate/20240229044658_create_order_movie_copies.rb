class CreateOrderMovieCopies < ActiveRecord::Migration[7.1]
  def change
    create_table :order_movie_copies do |t|
      t.userstamps
      t.datetime :deleted_at
      t.integer :movie_copy_id
      t.integer :order_id
      t.date :returned_on

      t.timestamps
    end
    add_index :order_movie_copies, :movie_copy_id
    add_index :order_movie_copies, :order_id
  end
end
