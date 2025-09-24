class AddAvgUserRatingsToMovies < ActiveRecord::Migration[7.1]
  def change
    add_column :movies, :avg_user_ratings, :float
  end
end
