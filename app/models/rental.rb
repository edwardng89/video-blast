class Rental < ApplicationRecord
  belongs_to :user, class_name: "Tempest::User"
  has_many :rental_items, dependent: :destroy
  has_many :copies, through: :rental_items

  after_commit :enqueue_receipt_email, on: :create

  STATUSES = %w[ongoing returned overdue].freeze

  # Ensure required fields are present on creation
  before_validation :set_defaults,        on: :create
  before_validation :assign_order_number, on: :create

  validates :order_number, presence: true, uniqueness: true
  validates :order_status, inclusion: { in: STATUSES }, allow_nil: true

  # ---------- Scopes ----------
  scope :by_status, ->(status) {
    return all if status.blank?
    where(order_status: status)
  }

  scope :due_from, ->(date_str) {
    return all if date_str.blank?
    where("due_date >= ?", Date.strptime(date_str, "%d/%m/%Y")) rescue all
  }

  scope :due_to, ->(date_str) {
    return all if date_str.blank?
    where("due_date <= ?", Date.strptime(date_str, "%d/%m/%Y")) rescue all
  }

  scope :due_now, -> {
    where(order_status: "ongoing").where("due_date <= ?", Date.current)
  }

  scope :title_like, ->(q) {
    return all if q.blank?
    s = "%#{q.to_s.downcase.strip}%"
    joins(copies: :movie)
      .where("LOWER(movies.title) LIKE ? OR rentals.order_number ILIKE ?", s, s)
      .distinct
  }

  scope :not_returned, -> { where(returned_at: nil).where.not(order_status: "returned") }

  # Prioritize outstanding: overdue -> ongoing -> returned, then newest
  scope :priority_list, -> {
    order(Arel.sql(%(
      (return_date IS NULL AND due_date IS NOT NULL AND due_date < CURRENT_DATE) DESC,
      (return_date IS NULL) DESC,
      created_at DESC
    )))
  }

  # ---------- Instance helpers ----------
  def returned? = return_date.present? || returned_at.present?

  def overdue?
    !returned? && due_date.present? && due_date < Date.current
  end

  def status_label
    return "Returned" if returned?
    return "Overdue"  if overdue?
    (order_status.presence || "ongoing").capitalize
  end

  # Quantity-aware totals (prices stored in cents on copies.rental_cost)
  def total_price_cents
    rental_items
      .joins(:copy)
      .sum("copies.rental_cost * COALESCE(rental_items.quantity, 1)")
      .to_i
  end
  alias_method :total_cents, :total_price_cents

  def total_price
    total_price_cents / 100.0
  end

  def mark_returned!
    transaction do
      self.return_date  ||= Date.current
      self.returned_at  ||= Time.current
      self.order_status   = "returned"
      save!
    end
  end

  def email_titles
    return order_titles if respond_to?(:order_titles) && order_titles.present?
    copies.includes(:movie).map { |c| c.movie&.title }.compact.uniq
  end

  def order_titles
    copies.includes(:movie).map { |c| "#{c.movie&.title} (#{c.copy_format})" }.join(", ")
  end

  private

  # Example: R20250924ABC123 (date + random)
  def assign_order_number
    self.order_number ||= "R#{Date.current.strftime('%Y%m%d')}#{SecureRandom.hex(3).upcase}"
  end

  def set_defaults
    self.order_status ||= "ongoing"
    self.rental_date  ||= Date.current
    self.due_date     ||= rental_date + 7.days
  end

  def enqueue_receipt_email
    SendReceiptJob.perform_later(self.id)
  end
end
