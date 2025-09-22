class Genre < ApplicationRecord
   has_many :video_genres, dependent: :destroy
   has_many :movies, through: :video_genres

   validates :name, presence: true, uniqueness: true

   scope :in_order, -> { order(:name) }
   scope :active,   -> { where(active: true) }
   scope :inactive, -> { where(active: false) }

   # simple search on name
   scope :search, ->(term) {
      return all if term.blank?
      where("LOWER(name) LIKE ?", "%#{term.to_s.downcase.strip}%")
   }
end
