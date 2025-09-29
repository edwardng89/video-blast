require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("Tempest::User") }
    it { is_expected.to belong_to(:movie) }
  end

  describe "validations" do
    it "requires format" do
      notification = build(:notification, format: nil)
      expect(notification).not_to be_valid
      expect(notification.errors[:format]).to include("can't be blank")
    end

    it "does not allow the same user/movie/format combination twice" do
      user  = create(:tempest_user)
      movie = create(:movie)

      create(:notification, user:, movie:, format: "DVD")
      duplicate = build(:notification, user:, movie:, format: "DVD")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("is already on this waitlist")
    end

    it "allows the same user/movie with a different format" do
      user  = create(:tempest_user)
      movie = create(:movie)

      create(:notification, user:, movie:, format: "DVD")
      second = build(:notification, user:, movie:, format: "Blu-ray")

      expect(second).to be_valid
    end
  end

  describe "scopes" do
    it ".pending returns only unfulfilled and unnotified records" do
      pending_notification   = create(:notification, fulfilled: false, notified_at: nil)
      fulfilled_notification = create(:notification, fulfilled: true,  notified_at: Time.current)
      notified_notification  = create(:notification, fulfilled: false, notified_at: Time.current)

      result = Notification.pending

      expect(result).to include(pending_notification)
      expect(result).not_to include(fulfilled_notification)
      expect(result).not_to include(notified_notification)
    end
  end
end
