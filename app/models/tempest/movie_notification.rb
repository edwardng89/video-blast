##
# Movie Notification
class Tempest::MovieNotification < ApplicationRecord
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :user
  validates_presence_of :requested_on
  validates_presence_of :movie_copy

  belongs_to :movie_copy, class_name: '::MovieCopy'

  belongs_to :user, class_name: '::User'
  # -- Scope methods start --
  # -- Scope methods end --

  # -- Sort methods start --

  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  sort_option :requested_on, lambda {
    order(Arel.sql('(movie_notifications.requested_on)'))
  }
  # -- Sort methods end --

  # -- Instance methods start --

  ##
  # movie format
  def movie_format; end

  ##
  # Inactive if canceled on is in the past
  def status; end
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
