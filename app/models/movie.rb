require "zlib"

class Movie < ApplicationRecord
  # ---------- Attachments ----------
  has_one_attached :cover

  # ---------- Associations ----------
  has_many :video_genres, dependent: :destroy, class_name: "VideoGenre"
  has_many :genres, through: :video_genres

  has_many :ratings, dependent: :destroy

  has_many :castings, dependent: :destroy
  has_many :actors, through: :castings

  has_many :copies, dependent: :destroy

  # ---------- Validations ----------
  validates :title, :content_rating, :released_on, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  validates :cover,
           content_type: { in: %w[image/jpeg image/png image/gif],
                           message: "must be a valid image format" },
           size:         { less_than: 5.megabytes,
                           message: "should be less than 5MB" }

  before_validation :ensure_avg_rating, on: :create

  # ---------- Scopes ----------
  scope :search, ->(q) {
    if q.present?
      s = ActiveRecord::Base.sanitize_sql_like(q.to_s.strip)
      where("title ILIKE :q OR description ILIKE :q", q: "%#{s}%")
    else
      all
    end
  }

  scope :in_order, ->(opt) {
    case opt
    when "released_desc" then order(released_on: :desc, title: :asc)
    when "released_asc"  then order(released_on: :asc,  title: :asc)
    when "updated_desc"  then order(updated_at: :desc)
    else                      order(title: :asc)
    end
  }

  # ---------- Helpers ----------
  def avg_stars
    if has_attribute?(:avg_stars)
      self[:avg_stars]&.to_f
    else
      ratings.average(:stars)&.to_f
    end
  end

  def average_rating
    avg = avg_stars
    return avg.round(1) if avg
    seeded_fake_rating
  end

  def release_year
    released_on&.year
  end

  def image_thumb = cover.attached? ? cover.variant(resize_to_fill: [320, 180]) : nil
  def image_card  = cover.attached? ? cover.variant(resize_to_fill: [500, 360]) : nil

  def cover_or_placeholder(width: 400, height: 450)
    if cover.attached?
      cover.variant(resize_to_fill: [width, height])
    else
      ActionController::Base.helpers.asset_path("placeholder-#{width}x#{height}.png")
    end
  end

  private
  
  def seeded_fake_rating
    seed = Zlib.crc32("#{id}-#{title}")
    rng  = Random.new(seed)
    rng.rand(1.0..5.0).round(1)
  end

  def ensure_avg_rating
    self.avg_user_ratings ||= 0.0
  end
end
