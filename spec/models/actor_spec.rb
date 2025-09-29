require "rails_helper"

RSpec.describe Actor, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:castings).dependent(:destroy) }
    it { is_expected.to have_many(:movies).through(:castings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
  end

  describe "#name" do
    it "concatenates first and last name" do
      actor = build(:actor, first_name: "Tom", last_name: "Hanks")
      expect(actor.name).to eq("Tom Hanks")
    end
  end

  describe "scopes" do
    let!(:actor1) { create(:actor, first_name: "Alice", last_name: "Zephyr") }
    let!(:actor2) { create(:actor, first_name: "Bob", last_name: "Anderson") }

    it ".in_order sorts by last name then first name" do
      expect(Actor.in_order).to eq([actor2, actor1])
    end

    it ".search finds matching names" do
      expect(Actor.search("alice")).to include(actor1)
      expect(Actor.search("zephyr")).to include(actor1)
      expect(Actor.search("bob")).to include(actor2)
      expect(Actor.search(nil)).to include(actor1, actor2)
    end
  end
end
