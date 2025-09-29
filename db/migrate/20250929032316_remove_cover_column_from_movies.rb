class RemoveCoverColumnFromMovies < ActiveRecord::Migration[7.1]
  def change
    remove_column :movies, :cover, :string
  end
end
