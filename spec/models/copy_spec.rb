# spec/models/copy_spec.rb
require "rails_helper"

RSpec.describe Copy, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:movie) }
    it { is_expected.to have_many(:rental_items).dependent(:destroy) }
    it { is_expected.to have_many(:rentals).through(:rental_items) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:copy_format) }

    it do
      is_expected.to validate_numericality_of(:no_of_copies)
        .only_integer
        .is_greater_than_or_equal_to(0)
    end

    it do
      is_expected.to validate_numericality_of(:rental_cost)
        .only_integer
        .is_greater_than_or_equal_to(0)
        .allow_nil
    end
  end

  describe "instance methods" do
    let(:movie) { create(:movie) }
    let(:copy)  { create(:copy, movie:, no_of_copies: 3, rental_cost: 500, copy_format: "DVD") }
    let(:user)  { create(:tempest_user) }

    describe "#rental_cost_dollars" do
      it "returns rental cost in dollars" do
        expect(copy.rental_cost_dollars).to eq(5.0) # 500 cents
      end
    end

    describe "#rental_cost_dollars=" do
      it "sets rental_cost in cents" do
        copy.rental_cost_dollars = 7.25
        expect(copy.rental_cost).to eq(725)
      end
    end

    describe "#outstanding" do
      it "counts rentals that are not returned" do
        rental = create(:rental) # factory handles user association
        create(:rental_item, rental:, copy:, quantity: 1)

        expect(copy.outstanding).to eq(1)

        rental.update!(returned_at: Time.current, order_status: "returned")
        expect(copy.outstanding).to eq(0)
      end
    end


    describe "#on_hand" do
      it "returns available copies" do
        rental = create(:rental, user:)
        create(:rental_item, rental:, copy:, quantity: 2)

        expect(copy.on_hand).to eq(1) # 3 total - 2 outstanding
      end

      it "never returns negative numbers" do
        rental = create(:rental, user:)
        create(:rental_item, rental:, copy:, quantity: 5)

        expect(copy.on_hand).to eq(0)
      end
    end
  end
end
