class Actor < ApplicationRecord
  # Associations
  has_many :castings, dependent: :destroy
  has_many :movies, through: :castings

  # Validations
  validates :first_name, presence: true
  validates :last_name,  presence: true

  def name
    "#{first_name} #{last_name}"
  end

  GENDERS = %w[male female non_binary other].freeze

  scope :in_order, -> { order(:last_name, :first_name) }

  # search on first_name + last_name
  scope :search, ->(term) {
    return all if term.blank?
    s = term.to_s.downcase.strip
    where("LOWER(first_name) LIKE :s OR LOWER(last_name) LIKE :s", s: "%#{s}%")
  }
end
