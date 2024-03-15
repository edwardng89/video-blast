##
# User
class Tempest::User < ApplicationRecord

  # Define classy enum and enum
  # FIXME: define your role enum and others here
  include ClassyEnum::ActiveRecord
  classy_enum_attr :enum_name, allow_blank: true, allow_nil: true


  # Userstamper gem setup
  model_stamper
  stampable optional: true

  # Soft delete gem setup
  acts_as_paranoid

  # define validation for your columns
  validates_presence_of :column_name

  # Define your relationships here
  has_many :model_name, class_name: '::ModelClass'

  # -- Scope methods start --
  scope :query, lambda { |query|
    where("SQL HERE")
  }

  # -- Scope methods end --

  # -- Sort methods start --

  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  sort_option :sort_name, lambda { order('...') }

  # -- Sort methods end --

  # FIXME: define any boolean using humanize to display nicely on screens
  humanize :boolean_column_name, boolean: true

  # -- Instance methods start --
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # -- Private methods start --
  # -- Private methods end --
end

