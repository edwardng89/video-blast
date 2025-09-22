class Movie < ApplicationRecord
    
    has_one_attached :cover

    # ------------------ VALIDATION-------------------
    validates :title, presence: true
    validates :content_rating, presence: true
    validates :released_on, presence: true
    validates :description, presence: true, length: { minimum: 10 }

    validates :cover,
              content_type: { in: %w[image/jpeg image/png image/gif],
                      message: "must be a valid image format" },
              size: { less_than: 5.megabytes,
              message: "should be less than 5MB" }

    # Genres (new join)
    has_many :video_genres
    has_many :genres, through: :video_genres
    

    # Actors (child list via castings)
    has_many :castings, dependent: :destroy
    has_many :actors, through: :castings

    has_many :copies, dependent: :destroy

    # accepts_nested_attributes_for :castings, allow_destroy: true
    # accepts_nested_attributes_for :actors

    validates :title, presence: true

    # Thumbnails (variants)
    def image_thumb   = cover.variant(resize_to_fill: [320, 180]) # list/grid
    def image_card    = cover.variant(resize_to_fill: [500, 360]) # show page

  scope :search, ->(q) {
    if q.present?
      s = sanitize_sql_like(q)
      where("title ILIKE :q OR description ILIKE :q", q: "%#{s}%")
    else
      all
    end
  }

  scope :in_order, ->(opt) {
    case opt
    when "year_desc"    then order(year: :desc, title: :asc)
    when "year_asc"     then order(year: :asc,  title: :asc)
    when "updated_desc" then order(updated_at: :desc)
    else                     order(title: :asc)
    end
  }

   # Returns a resized image for display.
  def display_image
    return unless cover.attached?
    cover.variant(resize_to_limit: [300, 300]).processed
  end

end
