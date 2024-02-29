##
#
class Tempest::MovieCopy < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :format, class_name: 'Format', allow_blank: true,
                            allow_nil: true

  acts_as_paranoid
  stampable optional: true

  monetize :rental_price_cents
  validates_presence_of :rental_price
  validates_presence_of :movie
  validates_presence_of :format

  belongs_to :movie, class_name: '::Movie'

  has_many :movie_notifications, class_name: '::MovieNotification'

  has_many :order_movie_copies, class_name: '::OrderMovieCopy'
  accepts_nested_attributes_for :movie_notifications
  accepts_nested_attributes_for :order_movie_copies
  # -- Scope methods start --
  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  humanize :active, boolean: true
  # -- Instance methods start --

  ##
  # On Hand
  def on_hand; end
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
