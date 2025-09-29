# spec/models/genre_spec.rb
require "rails_helper"

RSpec.describe Genre, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:video_genres).dependent(:destroy) }
    it { is_expected.to have_many(:movies).through(:video_genres) }
  end

  describe "validations" do
    subject { create(:genre) }  # ensures uniqueness validation has a record
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe "scopes" do
    let!(:active_genre)   { create(:genre, name: "Action", active: true) }
    let!(:inactive_genre) { create(:genre, name: "Romance", active: false) }

    it ".in_order sorts by name" do
      expect(Genre.in_order).to eq([active_genre, inactive_genre].sort_by(&:name))
    end

    it ".active returns only active genres" do
      expect(Genre.active).to include(active_genre)
      expect(Genre.active).not_to include(inactive_genre)
    end

    it ".inactive returns only inactive genres" do
      expect(Genre.inactive).to include(inactive_genre)
      expect(Genre.inactive).not_to include(active_genre)
    end

    it ".search finds matching names" do
      expect(Genre.search("act")).to include(active_genre)
      expect(Genre.search("rom")).to include(inactive_genre)
      expect(Genre.search(nil)).to include(active_genre, inactive_genre)
    end
  end
end
