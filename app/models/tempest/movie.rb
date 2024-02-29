##
# Movie
class Tempest::Movie < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :content_rating, class_name: 'ContentRating', allow_blank: true,
                                    allow_nil: true

  acts_as_paranoid
  stampable optional: true
  validates_presence_of :title
  validates_presence_of :released_on
  validates_presence_of :description
  validates_presence_of :content_rating

  mount_uploader :cover, FileUploader

  has_and_belongs_to_many :genres, class_name: '::Genre'

  has_many :movie_actors, class_name: '::MovieActor'

  has_many :movie_copies, class_name: '::MovieCopy'

  has_many :movie_genres, class_name: '::MovieGenre'

  has_many :user_ratings, class_name: '::UserRating'
  accepts_nested_attributes_for :genres
  accepts_nested_attributes_for :movie_actors
  accepts_nested_attributes_for :movie_copies
  accepts_nested_attributes_for :movie_genres
  accepts_nested_attributes_for :user_ratings
  # -- Scope methods start --
  scope :query, lambda { |query|
    where('movies.title ILIKE :query', query: "%#{query}%")
  }

  # -- Scope methods end --

  # -- Sort methods start --

  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  sort_option :title, lambda {
    order(Arel.sql('LOWER(movies.title)'))
  }
  # -- Sort methods end --

  humanize :active, boolean: true
  # -- Instance methods start --
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
