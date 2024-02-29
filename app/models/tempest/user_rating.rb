##
#
class Tempest::UserRating < ApplicationRecord
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :user
  validates_presence_of :rating
  validates_presence_of :movie

  belongs_to :movie, class_name: '::Movie'

  belongs_to :user, class_name: '::User'
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
