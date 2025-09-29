class Notification < ApplicationRecord
  belongs_to :user, class_name: "Tempest::User"
  belongs_to :movie

  validates :format, presence: true
  validates :user_id, uniqueness: { scope: [:movie_id, :format],
                                    message: "is already on this waitlist" }

  scope :pending, -> { where(fulfilled: false, notified_at: nil) }
end
