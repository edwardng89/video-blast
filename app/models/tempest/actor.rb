##
#
class Tempest::Actor < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :gender, class_name: 'Gender', allow_blank: true,
                            allow_nil: true

  acts_as_paranoid
  stampable optional: true
  validates_presence_of :last_name
  validates_presence_of :gender
  validates_presence_of :first_name

  has_many :movie_actors, class_name: '::MovieActor'
  accepts_nested_attributes_for :movie_actors
  # -- Scope methods start --
  scope :query, lambda { |query|
    where("actors.first_name ILIKE :query
OR actors.last_name ILIKE :query", query: "%#{query}%")
  }

  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  # -- Instance methods start --

  ##
  # name
  def name
    "#{first_name} #{last_name}"
  end
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
