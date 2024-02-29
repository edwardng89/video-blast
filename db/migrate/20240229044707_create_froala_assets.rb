class CreateFroalaAssets < ActiveRecord::Migration[7.1]
  def change
    create_table :froala_assets do |t|
      t.string :file, null: false
      t.string  :file_name
      t.string  :content_type
      t.integer :file_size
      t.string  :type, limit: 30, index: true
      t.integer :width
      t.integer :height
      t.boolean :gallery, index: true

      t.timestamps
    end
  end
end
