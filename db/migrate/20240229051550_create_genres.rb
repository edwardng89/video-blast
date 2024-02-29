class CreateGenres < ActiveRecord::Migration[7.1]
  def change
    create_table :genres do |t|
      t.userstamps
      t.datetime :deleted_at
      t.boolean :active
      t.string :name
      t.integer :sort_order

      t.timestamps
    end
  end
end
