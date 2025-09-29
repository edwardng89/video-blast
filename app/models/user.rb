class User < Tempest::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :rentals
  has_many :notifications, dependent: :destroy
  # Devise setup
  devise :invitable, :trackable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

         
  # CSV export
  def self.to_csv
    attributes = %w[id first_name last_name email role active created_at]

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  # XLS export (simple tab-separated, works with Excel)
  def self.to_xls
    attributes = %w[id first_name last_name email role active created_at]

    ([attributes.join("\t")] +
      all.map { |u| attributes.map { |attr| u.send(attr) }.join("\t") })
      .join("\n")
  end
  # Search function
  def self.search(term)
    return all if term.blank?

    escaped = ActiveRecord::Base.sanitize_sql_like(term.to_s.strip)
    where(
      "first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
      q: "%#{escaped}%"
    )
  end

  # helpful rollups
  def last_order_at = orders.maximum(:created_at)
  def total_spend   = orders.sum(:total_cents)

  def outstanding_orders
    orders.outstanding
  end

  def to_s
    [first_name, last_name].compact.join(" ").presence || email
  end


end

