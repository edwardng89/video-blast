class CreateMovieCopies < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_copies do |t|
      t.userstamps
      t.datetime :deleted_at
      t.boolean :active
      t.integer :copies
      t.string :format
      t.integer :movie_id
      t.monetize :rental_price

      t.timestamps
    end
    add_index :movie_copies, :movie_id
  end
end
