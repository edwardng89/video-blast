##
#
class Tempest::User < ApplicationRecord
  include ClassyEnum::ActiveRecord
  classy_enum_attr :state, class_name: 'State', allow_blank: true,
                           allow_nil: true

  classy_enum_attr :role, class_name: 'AdminRole', allow_blank: true,
                          allow_nil: true

  classy_enum_attr :gender, class_name: 'Gender', allow_blank: true,
                            allow_nil: true

  model_stamper
  acts_as_paranoid
  stampable optional: true
  validates_presence_of :suburb
  validates_presence_of :state
  validates_presence_of :postcode
  validates_presence_of :last_name
  validates_presence_of :gender
  validates_presence_of :first_name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_presence_of :address_line_1

  has_many :movie_notifications, class_name: '::MovieNotification'

  has_many :orders, class_name: '::Order'

  has_many :user_ratings, class_name: '::UserRating'
  accepts_nested_attributes_for :movie_notifications
  accepts_nested_attributes_for :orders
  accepts_nested_attributes_for :user_ratings
  # -- Scope methods start --
  scope :query, lambda { |query|
    where("users.address_line_1 ILIKE :query
OR users.address_line_2 ILIKE :query
OR users.email ILIKE :query
OR users.first_name ILIKE :query
OR users.last_name ILIKE :query
OR users.password ILIKE :query
OR users.postcode ILIKE :query
OR users.suburb ILIKE :query", query: "%#{query}%")
  }

  # -- Scope methods end --

  # -- Sort methods start --
  # -- Sort methods end --

  humanize :active, boolean: true
  humanize :admin, boolean: true
  # -- Instance methods start --

  ##
  # Name
  def name
    "#{first_name} #{last_name}"
  end

  ##
  # To initialize tokens for letter template content
  def to_liquid
    UserMergeField.new(self)
  end
  # -- Instance methods end --

  alias to_s name

  # -- Class methods start --
  # -- Class methods end --

  # FIXME: Update to use a single private def and indent below
  # -- Private methods start --
  # -- Private methods end --
end

class UserMergeField < Liquid::Drop
  def initialize(user)
    @user = user
    @user = user.respond_to?(:recipient) && user.recipient.present? ? user.recipient : user&.user
    return unless user.trigger_record_id.present?

    class_name = user.trigger_record_class.present? ? user.trigger_record_class : user.comm_trigger.anchor_model
    instance_variable_set('@' + class_name.underscore.parameterize,
                          class_name.constantize.find(user.trigger_record_id))
  end

  # -- Liquid methods start --
  private def password_reset_url_description
    'liquid token for reset password url'
  end
  def password_reset_url
    Rails.application.routes.url_helpers.edit_person_password_url(reset_password_token:
                                   @User.send(:set_reset_password_token))
  end
  private def signup_confirmation_url_description
    'liquid token for password confirmation'
  end
  def signup_confirmation_url
    Rails.application.routes.url_helpers.person_confirmation_url(confirmation_token:
                                   @User.send(:generate_confirmation_token))
  end
  # -- Liquid methods end --
end
