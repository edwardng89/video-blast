class CreateUserRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :user_ratings do |t|
      t.userstamps
      t.datetime :deleted_at
      t.integer :movie_id
      t.integer :rating
      t.integer :user

      t.timestamps
    end
    add_index :user_ratings, :movie_id
  end
end
