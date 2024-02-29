class CreateActors < ActiveRecord::Migration[7.1]
  def change
    create_table :actors do |t|
      t.userstamps
      t.datetime :deleted_at
      t.date :birth_date
      t.string :first_name
      t.string :gender
      t.string :last_name

      t.timestamps
    end
  end
end
