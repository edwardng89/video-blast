##
# Movie Genre
class Tempest::MovieGenre < ApplicationRecord
  include RailsSortable::Model
  set_sortable :sort_order
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :movie
  validates_presence_of :genre

  belongs_to :genre, class_name: '::Genre'

  belongs_to :movie, class_name: '::Movie'
  # -- Scope methods start --
  # -- Scope methods end --

  # -- Sort methods start --

  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  sort_option :sort_order, lambda {
    order(Arel.sql('(movie_genres.sort_order)'))
  }
  # -- Sort methods end --

  # -- Instance methods start --
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
