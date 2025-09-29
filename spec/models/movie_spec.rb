# frozen_string_literal: true
require "rails_helper"

RSpec.describe Movie, type: :model do
  # ---------------- VALIDATIONS ----------------
  describe "validations" do
    it "is invalid without a title" do
      movie = build(:movie, title: nil)
      expect(movie).not_to be_valid
      expect(movie.errors[:title]).to include("can't be blank")
    end

    it "is invalid without a content_rating" do
      movie = build(:movie, content_rating: nil)
      expect(movie).not_to be_valid
      expect(movie.errors[:content_rating]).to include("can't be blank")
    end

    it "is invalid without a released_on date" do
      movie = build(:movie, released_on: nil)
      expect(movie).not_to be_valid
      expect(movie.errors[:released_on]).to include("can't be blank")
    end

    it "is invalid without a description" do
      movie = build(:movie, description: nil)
      expect(movie).not_to be_valid
      expect(movie.errors[:description]).to include("can't be blank")
    end

    it "is invalid if description is too short" do
      movie = build(:movie, description: "short")
      expect(movie).not_to be_valid
      expect(movie.errors[:description]).to include(/is too short/)
    end
  end

  # ---------------- SCOPES ----------------
  describe ".search" do
    let!(:m1) { create(:movie, title: "Star Wars", description: "Epic space opera") }
    let!(:m2) { create(:movie, title: "The Notebook", description: "Romantic drama") }

    it "finds movies by title" do
      expect(described_class.search("Star")).to include(m1)
      expect(described_class.search("Star")).not_to include(m2)
    end

    it "finds movies by description" do
      expect(described_class.search("romantic")).to include(m2)
    end

    it "returns all when query is blank" do
      expect(described_class.search(nil)).to match_array([m1, m2])
    end
  end

  describe ".in_order" do
    let!(:older) { create(:movie, title: "A", released_on: 2.years.ago, updated_at: 5.days.ago) }
    let!(:newer) { create(:movie, title: "B", released_on: 1.year.ago, updated_at: 1.day.ago) }

    it "orders by released_on desc then title asc" do
      expect(described_class.in_order("released_desc")).to eq([newer, older])
    end

    it "orders by released_on asc then title asc" do
      expect(described_class.in_order("released_asc")).to eq([older, newer])
    end

    it "orders by updated_at desc" do
      expect(described_class.in_order("updated_desc")).to eq([newer, older])
    end

    it "defaults to title asc" do
      expect(described_class.in_order(nil).pluck(:title)).to eq(%w[A B])
    end
  end

  # ---------------- INSTANCE METHODS ----------------
  describe "#avg_stars" do
    let(:movie) { create(:movie) }

    it "returns nil when no ratings" do
      expect(movie.avg_stars).to be_nil
    end
  end

  describe "#average_rating" do
    let(:movie) { create(:movie) }

    it "falls back to seeded_fake_rating when unrated" do
      expect(movie.average_rating).to be_between(1.0, 5.0)
    end
  end

  describe "#release_year" do
    it "returns the year of released_on" do
      movie = build(:movie, released_on: Date.new(1999, 12, 31))
      expect(movie.release_year).to eq(1999)
    end
  end

  describe "#cover_or_placeholder" do
    let(:movie) { build(:movie) }

    it "returns a variant if cover is attached" do
      # ensure fixture exists: spec/fixtures/files/batman.jpg
      FileUtils.mkdir_p(Rails.root.join("spec/fixtures/files"))
      sample = Rails.root.join("spec/fixtures/files/batman.jpg")
      File.write(sample, "fake image data") unless File.exist?(sample)

      movie.cover.attach(
        io: File.open(sample),
        filename: "batman.jpg",
        content_type: "image/jpeg"
      )

      result = movie.cover_or_placeholder

      # Rails 7 uses VariantWithRecord, older versions use Variant
      expect(result).to be_a(ActiveStorage::Variant) | be_a(ActiveStorage::VariantWithRecord)
    end
  end

end
