class CreateCopies < ActiveRecord::Migration[7.1]
  def change
    create_table :copies do |t|
      t.references :movie, null: false, foreign_key: true
      t.string :copy_format, null: false
      t.string :status, default: "available"
      t.timestamps
    end
  end
end
