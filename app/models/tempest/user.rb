##
# User
class Tempest::User < ApplicationRecord

  # Define classy enum and enum
  # FIXME: define your role enum and others here
  include ClassyEnum::ActiveRecord
  # classy_enum_attr :enum_name, allow_blank: true, allow_nil: true

  # Userstamper gem setup
  model_stamper
  stampable optional: true

  enum role: { user: "user", admin: "admin", super_admin: "super_admin" }

  before_validation :normalize_fields

  AU_STATES = %w[SA NSW VIC QLD WA TAS NT ACT].freeze
  AU_POSTCODE = /\A\d{4}\z/
  ROLE_OPTIONS = ["User", "Admin", "Super Admin"].freeze
  GENDER_OPTIONS = ["male", "female", "other"].freeze # adjust to your list

  # ---- Required on CREATE ----
  validates :first_name, :last_name, presence: true, on: :create

  # ---- Always required/validated ----
  validates :email,
           presence: true,
           length: { maximum: 255 },
           format: { with: URI::MailTo::EMAIL_REGEXP },
           uniqueness: { case_sensitive: false }

  # Optional fields but constrained when present
  validates :gender, inclusion: { in: GENDER_OPTIONS, message: "is not valid" }, allow_blank: true
  validates :state,  inclusion: { in: AU_STATES, message: "must be an Australian state/territory" }, allow_blank: true
  validates :postcode, format: { with: AU_POSTCODE, message: "must be 4 digits" }, allow_blank: true
  validates :suburb, length: { maximum: 80 }, allow_blank: true
  validates :address_line_1, :address_line_2, length: { maximum: 255 }, allow_blank: true

  # Role (string column) – if you already use an integer enum, see enum option below
  validates :role, presence: true, on: :create

  # Booleans
  #validates :active, inclusion: { in: [true, false] }

  # If the gender select has a "Please Select" placeholder, reject it explicitly
  validate :reject_gender_placeholder

  before_validation :set_default_role


  def admin?
    self.admin || role.in?(%w[admin super_admin])
  end

  def user?
    !admin?
  end

  def name
    [first_name, last_name].reject(&:blank?).join(" ").presence || email
  end

  private

  def set_default_role
    self.role ||= "user"   # <- default for public signups
  end

  def normalize_fields
    self.first_name = first_name.to_s.strip.squish.titleize
    self.last_name  = last_name.to_s.strip.squish.titleize
    self.email      = email.to_s.strip.downcase
    self.suburb     = suburb.to_s.strip.squish.titleize
    self.state      = state.to_s.strip.upcase.presence
    self.postcode   = postcode.to_s.gsub(/\D/, "") # keep digits only
  end

  def reject_gender_placeholder
    errors.add(:gender, "must be selected") if gender.to_s.downcase == "please select"
  end 

  # Whitelist of allowed sort keys → actual ORDER clauses
  SORT_MAP = {
    "name_asc"       => Arel.sql("last_name ASC, first_name ASC"),
    "name_desc"      => Arel.sql("last_name DESC, first_name DESC"),
    "email_asc"      => Arel.sql("email ASC"),
    "email_desc"     => Arel.sql("email DESC"),
    "created_at_asc" => Arel.sql("created_at ASC"),
    "created_at_desc"=> Arel.sql("created_at DESC")
  }.freeze

  def self.default_sort_option
    "name_asc"
  end

  # has_scope will pass the param value (or default) into this scope
  scope :in_order, ->(sort_key) {
    order(SORT_MAP[sort_key] || SORT_MAP[default_sort_option])
  }
  
  # Optional: for a dropdown on the UI
  def self.sort_options_for_select
    [
      ["Name (A → Z)",       "name_asc"],
      ["Name (Z → A)",       "name_desc"],
      ["Email (A → Z)",      "email_asc"],
      ["Email (Z → A)",      "email_desc"],
      ["Oldest first",       "created_at_asc"],
      ["Newest first",       "created_at_desc"]
    ]
  end

  # Soft delete gem setup
  acts_as_paranoid

  # define validation for your columns
  # validates_presence_of :column_name

  # Define your relationships here
  # has_many :model_name, class_name: '::ModelClass'

  # -- Scope methods start --
  # scope :query, lambda { |query|
  #   where("SQL HERE")
  # }

  # -- Scope methods end --

  # -- Sort methods start --
  # has_scope will pass the param value (or default) into this scope
  scope :in_order, ->(sort) {
    case sort
    when "name_asc"        then order(first_name: :asc, last_name: :asc)
    when "name_desc"       then order(first_name: :desc, last_name: :desc)
    when "email_asc"       then order(email: :asc)
    when "email_desc"      then order(email: :desc)
    when "created_at_asc"  then order(created_at: :asc)
    when "created_at_desc" then order(created_at: :desc)
    else
      order(first_name: :asc, last_name: :asc) # default
    end
  }
  
  # Optional: for a dropdown on the UI
  def self.sort_options_for_select
    [
      ["Name (A → Z)",       "name_asc"],
      ["Name (Z → A)",       "name_desc"],
      ["Email (A → Z)",      "email_asc"],
      ["Email (Z → A)",      "email_desc"],
      ["Oldest first",       "created_at_asc"],
      ["Newest first",       "created_at_desc"]
    ]
  end
  ##
  # +SortOption+ Sort Method
  # @!scope class
  # @return (Sort Option)
  # sort_option :sort_name, lambda { order('...') }

  # -- Sort methods end --

  # FIXME: define any boolean using humanize to display nicely on screens
  # humanize :boolean_column_name, boolean: true

  # -- Instance methods start --
  # -- Instance methods end --

  # -- Class methods start --
  # -- Class methods end --

  # -- Private methods start --
  # -- Private methods end --
end

