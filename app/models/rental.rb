class Rental < ApplicationRecord
  belongs_to :user
  has_many :rental_items, dependent: :destroy
  has_many :copies, through: :rental_items
  after_commit :enqueue_receipt_email, on: :create  

  STATUSES = %w[ongoing returned overdue].freeze

  # ---- make sure order_number always set ----
  before_validation :assign_order_number, on: :create
  validates :order_number, presence: true, uniqueness: true
  # -----------------------------------------------

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
    where(order_status: "ongoing")
      .where("due_date <= ?", Date.current)
  }

  scope :title_like, ->(q) {
    return all if q.blank?
    s = "%#{q.to_s.downcase.strip}%"
    joins(copies: :movie).where("LOWER(movies.title) LIKE ? OR rentals.order_number ILIKE ?", s, s).distinct
  }

  # Already-returned?
  scope :not_returned, -> { where(returned_at: nil).where.not(order_status: "returned") }

  # ---- scopes your job expects ----
  scope :needs_gentle_on, ->(today) {
    not_returned.where("due_date < ?", today).where(overdue_notice_sent_at: nil)
  }
  scope :needs_escalation_on, ->(date) {
    not_returned
      .where("due_date < ?", date - 2.days)
      .where(overdue_escalation_sent_at: nil)
  }

  def mark_returned!
    transaction do
      self.return_date  ||= Date.current
      self.returned_at  ||= Time.current
      self.order_status   = "returned"
      save!
      # copies.each { |c| c.increment!(:available_quantity) }
    end
  end

  def email_titles
    return order_titles if respond_to?(:order_titles) && order_titles.present?
    copies.includes(:movie).map { |c| c.movie&.title }.compact.uniq
  end

  def order_titles
    copies.includes(:movie).map { |c| "#{c.movie&.title} (#{c.copy_format})" }.join(", ")
  end

  def total_price_cents
    rental_items.joins(:copy).sum("copies.rental_cost")
  end

  def total_price
    total_price_cents.to_f / 100
  end

  private

  ### NEW: auto-generate order_number
  def assign_order_number
    # Example: "R202509170001"
    self.order_number ||= "R#{Date.current.strftime('%Y%m%d')}#{SecureRandom.hex(3).upcase}"
  end

  def enqueue_receipt_email
    SendReceiptJob.perform_later(self.id)
  end

end
