##
# Genre
class Tempest::Genre < ApplicationRecord
  include RailsSortable::Model
  set_sortable :sort_order
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :name

  has_many :movie_genres, class_name: '::MovieGenre'

  has_and_belongs_to_many :movies, class_name: '::Movie', dependent: :restrict_with_error
  accepts_nested_attributes_for :movie_genres
  accepts_nested_attributes_for :movies
  # -- Scope methods start --
  scope :query, lambda { |query|
    where('genres.name ILIKE :query', query: "%#{query}%")
  }

  # -- Scope methods end --

  # -- Sort methods start --

  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  sort_option :sort_order, lambda {
    order(Arel.sql('(genres.sort_order)'))
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
