##
# Communication Record Model
class Tempest::CommunicationRecord < ApplicationRecord
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :to
  validates_presence_of :subject
  validates_presence_of :from

  belongs_to :communication_recordable, polymorphic: true
  # -- Scope methods start --
  scope :query, lambda { |query|
    where("communication_records.communication_recordable_type ILIKE :query
OR communication_records.from ILIKE :query
OR communication_records.subject ILIKE :query
OR communication_records.to ILIKE :query", query: "%#{query}%")
  }

  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  # -- Instance methods start --

  ##
  # Get the received status of the communication record as a boolean
  def received?
    received_at.present?
  end

  ##
  # Get the sent status of the communication record as a boolean
  def sent?
    sent_at.present? || received_at.present?
  end

  ##
  # Get the status of the communication record as a symbol
  def status
    return :received if received?
    return :sent if sent?

    :unsent
  end
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end
