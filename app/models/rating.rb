class Rating < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  # stars is an integer (0..5)
  validates :stars, inclusion: { in: 0..5 }
end
