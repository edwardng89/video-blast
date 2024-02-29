class CreateMovieActors < ActiveRecord::Migration[7.1]
  def change
    create_table :movie_actors do |t|
      t.userstamps
      t.datetime :deleted_at
      t.integer :actor_id
      t.integer :movie_id
      t.integer :sort_order

      t.timestamps
    end
    add_index :movie_actors, :actor_id
    add_index :movie_actors, :movie_id
  end
end
