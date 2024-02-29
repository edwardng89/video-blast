##
#
class Tempest::OrderMovieCopy < ApplicationRecord
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :order
  validates_presence_of :movie_copy

  belongs_to :movie_copy, class_name: '::MovieCopy'

  belongs_to :order, class_name: '::Order'
  # -- Scope methods start --
  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  # -- Instance methods start --
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
