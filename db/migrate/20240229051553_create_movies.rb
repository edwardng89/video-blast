class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.userstamps
      t.datetime :deleted_at
      t.boolean :active
      t.string :content_rating
      t.string :cover
      t.text :description
      t.date :released_on
      t.string :title

      t.timestamps
    end
  end
end
