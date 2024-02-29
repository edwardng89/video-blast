##
# Order
class Tempest::Order < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :status, class_name: 'OrderStatus', allow_blank: true,
                            allow_nil: true

  acts_as_paranoid
  stampable optional: true
  validates_presence_of :user

  has_many :order_movie_copies, class_name: '::OrderMovieCopy'

  belongs_to :user, class_name: '::User'
  accepts_nested_attributes_for :order_movie_copies
  # -- Scope methods start --
  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  # -- Instance methods start --

  ##
  # Order Number
  def order_number
    id
  end
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
