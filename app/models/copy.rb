class Copy < ApplicationRecord
  belongs_to :movie
  has_many :rental_items, dependent: :destroy
  has_many :rentals, through: :rental_items

  alias_attribute :format, :copy_format

  validates :copy_format, presence: true
  validates :no_of_copies, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :rental_cost,  numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  STATUSES = ["available", "rented", "archived", "damaged"].freeze

  # rentals not yet returned
  def outstanding
    rentals.where(returned_at: nil).count
  end

  # rental_cost stored as integer cents
  def rental_cost_dollars
    (rental_cost.to_i / 100.0).round(2)
  end

  def rental_cost_dollars=(val)
    self.rental_cost = (BigDecimal(val.to_s) * 100).to_i
  end

  def on_hand
    [no_of_copies.to_i - outstanding, 0].max
  end
end
