##
# Movie Actor
class Tempest::MovieActor < ApplicationRecord
  include RailsSortable::Model
  set_sortable :sort_order
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :movie
  validates_presence_of :actor

  belongs_to :actor, class_name: '::Actor'

  belongs_to :movie, class_name: '::Movie'
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
