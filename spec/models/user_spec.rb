# frozen_string_literal: true
require "rails_helper"

RSpec.describe Tempest::User, type: :model do
  # ---------------- ENUMS ----------------
  describe "enums" do
    it "has the expected role values" do
      expect(described_class.roles).to eq(
        "user"        => "user",
        "admin"       => "admin",
        "super_admin" => "super_admin"
      )
    end

    it "responds to role helpers" do
      u = build(:tempest_user, role: "admin")
      expect(u.admin?).to be true
      u.role = "user"
      expect(u.user?).to be true
    end
  end

  # ---------------- VALIDATIONS ----------------
  describe "validations" do
    context "on create" do
      it "requires first_name" do
        u = build(:tempest_user, first_name: "")
        expect(u).not_to be_valid
        expect(u.errors[:first_name]).to be_present
      end

      it "requires last_name" do
        u = build(:tempest_user, last_name: "")
        expect(u).not_to be_valid
        expect(u.errors[:last_name]).to be_present
      end

      it "requires role" do
        u = build(:tempest_user, role: nil)
        expect(u).not_to be_valid
        expect(u.errors[:role]).to be_present
      end
    end

    it "requires email and limits it to 255 chars" do
      u = build(:tempest_user, email: "")
      expect(u).not_to be_valid
      expect(u.errors[:email]).to include(/can't be blank/i)

      long_local = "a" * 250
      too_long   = "#{long_local}@x.com" # >255
      u2 = build(:tempest_user, email: too_long)
      expect(u2).not_to be_valid
      expect(u2.errors[:email]).to include(/is too long/i)
    end

    it "validates email format" do
      good = build(:tempest_user, email: "a+b.test@example.co.uk")
      bad1 = build(:tempest_user, email: "bad@")
      bad2 = build(:tempest_user, email: "no-at.example.com")

      expect(good).to be_valid
      expect(bad1).not_to be_valid
      expect(bad2).not_to be_valid
      expect(bad1.errors[:email]).to be_present
      expect(bad2.errors[:email]).to be_present
    end

    it "validates email uniqueness case-insensitively" do
      create(:tempest_user, email: "dupe@example.com")
      dup = build(:tempest_user, email: "DUPE@example.com")
      expect(dup).not_to be_valid
      expect(dup.errors[:email]).to include(/already been taken/i)
    end

    it "validates gender inclusion when present" do
      expect(build(:tempest_user, gender: "male")).to be_valid

      invalid = build(:tempest_user, gender: "invalid")
      expect(invalid).not_to be_valid
      expect(invalid.errors[:gender]).to include("is not valid")
    end

    it "validates state inclusion when present" do
      expect(build(:tempest_user, state: "SA")).to be_valid

      bad = build(:tempest_user, state: "CA")
      expect(bad).not_to be_valid
      expect(bad.errors[:state]).to include("must be an Australian state/territory")
    end

    it "validates postcode format (4 digits) when present" do
      expect(build(:tempest_user, postcode: "5000")).to be_valid

      bad = build(:tempest_user, postcode: "500")
      expect(bad).not_to be_valid
      expect(bad.errors[:postcode]).to include("must be 4 digits")
    end

    it "limits suburb/address lengths when present" do
      expect(build(:tempest_user, suburb: "a" * 80)).to be_valid
      expect(build(:tempest_user, address_line_1: "a" * 255)).to be_valid
      expect(build(:tempest_user, address_line_2: "a" * 255)).to be_valid

      bad1 = build(:tempest_user, suburb: "a" * 81)
      bad2 = build(:tempest_user, address_line_1: "a" * 256)
      bad3 = build(:tempest_user, address_line_2: "a" * 256)

      [bad1, bad2, bad3].each do |u|
        expect(u).not_to be_valid
      end
    end
  end

  # ---------------- CUSTOM VALIDATOR ----------------
  describe "reject_gender_placeholder" do
    it "adds an error when gender is 'Please Select' (any case)" do
      user = build(:tempest_user, gender: "Please Select")
      expect(user).not_to be_valid
      expect(user.errors[:gender]).to include("must be selected")
    end
  end

  # ---------------- CALLBACKS ----------------
  describe "normalize_fields" do
    it "normalizes names, email, suburb, state and digits for postcode" do
      raw = {
        first_name: "  jAnE  ",
        last_name:  "  DOE ",
        email:      "  TEST+tag@Example.COM ",
        suburb:     "  port  noarlunga  ",
        state:      " sa ",
        postcode:   " 5-0 0a0 "
      }

      user = Tempest::User.new(raw.merge(role: "user"))

      # Run the callback directly (don’t depend on validations)
      user.send(:normalize_fields)

      aggregate_failures "normalized field properties" do
        # first_name
        expect(user.first_name).to eq(user.first_name.strip), "first_name should be trimmed"
        expect(user.first_name).to eq(user.first_name.squish), "first_name should be squished"
        expect(user.first_name).to eq(user.first_name.titleize), "first_name should be titleized"

        # last_name
        expect(user.last_name).to eq(user.last_name.strip), "last_name should be trimmed"
        expect(user.last_name).to eq(user.last_name.squish), "last_name should be squished"
        expect(user.last_name).to eq(user.last_name.titleize), "last_name should be titleized"

        # email
        expect(user.email).to eq(user.email.strip), "email should be trimmed"
        expect(user.email).to eq(user.email.downcase), "email should be downcased"

        # suburb
        expect(user.suburb).to eq(user.suburb.strip), "suburb should be trimmed"
        expect(user.suburb).to eq(user.suburb.squish), "suburb should be squished"
        expect(user.suburb).to eq(user.suburb.titleize), "suburb should be titleized"

        # state
        expect(user.state).to be_present
        expect(user.state).to eq(user.state.strip), "state should be trimmed"
        expect(user.state).to eq(user.state.upcase), "state should be upcased"

        # postcode (digits only)
        expect(user.postcode).to match(/\A\d*\z/), "postcode should contain digits only"
      end
    end

    it "sets blank state to nil" do
      user = build(:tempest_user, state: "   ")
      user.send(:normalize_fields)
      expect(user.state).to be_nil
    end
  end
   # ---------------- SORT ----------------
    describe ".in_order" do
    let!(:a) { create(:tempest_user, last_name: "Alpha", first_name: "Amy",  email: "a@example.com", created_at: 2.days.ago) }
    let!(:b) { create(:tempest_user, last_name: "Beta",  first_name: "Bob",  email: "b@example.com", created_at: 1.day.ago) }

    it "orders by name asc by default" do
      expect(described_class.in_order(nil).pluck(:last_name)).to eq(%w[Alpha Beta])
    end

    it "orders by name asc when requested" do
      expect(described_class.in_order("name_asc").pluck(:last_name)).to eq(%w[Alpha Beta])
    end

    it "orders by name desc when requested" do
      expect(described_class.in_order("name_desc").pluck(:last_name)).to eq(%w[Beta Alpha])
    end

    it "orders by email asc when requested" do
      expect(described_class.in_order("email_asc").pluck(:email)).to eq(%w[a@example.com b@example.com])
    end

    it "orders by email desc when requested" do
      expect(described_class.in_order("email_desc").pluck(:email)).to eq(%w[b@example.com a@example.com])
    end

    it "orders by created_at asc when requested" do
      expect(described_class.in_order("created_at_asc").pluck(:email)).to eq(%w[a@example.com b@example.com])
    end

    it "orders by created_at desc when requested" do
      expect(described_class.in_order("created_at_desc").pluck(:email)).to eq(%w[b@example.com a@example.com])
    end
  end




  # ---------------- SOFT DELETE ----------------
  describe "soft delete (acts_as_paranoid)" do
    it "marks record as deleted without removing it" do
      user = create(:tempest_user)
      user.destroy

      if described_class.respond_to?(:with_deleted)
        deleted = described_class.with_deleted.find(user.id)
        expect(deleted.deleted_at).to be_present

        if deleted.respond_to?(:really_destroy!)
          # ensure we can permanently delete when asked
          deleted.really_destroy!
          expect(described_class.with_deleted.where(id: user.id)).to be_none
        end
      else
        # Fallback check if paranoia scopes aren’t available
        expect(described_class.where(id: user.id)).to be_none
        expect(user.deleted_at).to be_present
      end
    end
  end

  # ---------------- HAPPY PATH ----------------
  describe "happy path create" do
    it "is valid with minimal required fields on create" do
      expect(build(:tempest_user)).to be_valid
    end
  end
end
