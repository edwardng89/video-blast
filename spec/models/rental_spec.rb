# spec/models/rental_spec.rb
require "rails_helper"

RSpec.describe Rental, type: :model do
  let(:user)   { create(:tempest_user) }
  let(:movie)  { create(:movie, title: "The Matrix") }
  let(:copy)   { create(:copy, movie:, rental_cost: 500, copy_format: "DVD", no_of_copies: 3) }
  let(:rental) { create(:rental, :with_item, user:) }

  describe "associations" do
    it { is_expected.to belong_to(:user).class_name("Tempest::User") }
    it { is_expected.to have_many(:rental_items).dependent(:destroy) }
    it { is_expected.to have_many(:copies).through(:rental_items) }
  end

  # spec/models/rental_spec.rb
  describe "validations" do
    subject { create(:rental, user: create(:tempest_user)) }

    it { is_expected.to validate_uniqueness_of(:order_number) }

    it "assigns an order number on create if missing" do
      rental = create(:rental, order_number: nil, user: create(:tempest_user))
      expect(rental.order_number).to be_present
    end

    it { is_expected.to allow_value("ongoing", "returned", "overdue").for(:order_status) }
    it { is_expected.not_to allow_value("invalid").for(:order_status) }
  end



  describe "callbacks" do
    it "sets defaults on create" do
      rental = build(:rental, user:, order_status: nil, rental_date: nil, due_date: nil, order_number: nil)
      rental.valid?
      expect(rental.order_status).to eq("ongoing")
      expect(rental.rental_date).to eq(Date.current)
      expect(rental.due_date).to eq(Date.current + 7.days)
      expect(rental.order_number).to be_present
    end

    it "assigns an order number on create" do
      expect(rental.order_number).to start_with("R#{Date.current.strftime('%Y%m%d')}")
    end

    it "enqueues a receipt email after create" do
      expect {
        create(:rental, user:)
      }.to have_enqueued_job(SendReceiptJob)
    end
  end

  describe "scopes" do
    let!(:ongoing_rental)  { create(:rental, user:, order_status: "ongoing", due_date: Date.current + 1.day) }
    let!(:overdue_rental)  { create(:rental, user:, order_status: "ongoing", due_date: Date.yesterday) }
    let!(:returned_rental) { create(:rental, user:, order_status: "returned", return_date: Date.yesterday) }

    it ".by_status filters correctly" do
      expect(Rental.by_status("returned")).to include(returned_rental)
      expect(Rental.by_status("returned")).not_to include(ongoing_rental)
    end

    it ".due_now returns overdue ongoing rentals" do
      expect(Rental.due_now).to include(overdue_rental)
      expect(Rental.due_now).not_to include(ongoing_rental)
    end

    it ".title_like finds by movie title or order number" do
      rental_with_movie = create(:rental, user:)
      create(:rental_item, rental: rental_with_movie, copy:)

      expect(Rental.title_like("matrix")).to include(rental_with_movie)
    end
  end

  describe "instance methods" do
    it "#returned? is true if returned_at or return_date present" do
      rental.update!(returned_at: Time.current)
      expect(rental.returned?).to be true
    end

    it "#overdue? is true if due_date < today and not returned" do
      rental.update!(due_date: Date.yesterday)
      expect(rental.overdue?).to be true
    end

    it "#status_label shows correct label" do
      rental.update!(due_date: Date.yesterday, order_status: "ongoing")
      expect(rental.status_label).to eq("Overdue")

      rental.update!(return_date: Date.today)
      expect(rental.status_label).to eq("Returned")
    end

    it "#total_price_cents sums copy rental_cost × quantity" do
      rental_item = rental.rental_items.first
      rental_item.update!(quantity: 2)
      expect(rental.total_price_cents).to eq(copy.rental_cost * 2)
    end

    it "#total_price converts cents to dollars" do
      expect(rental.total_price).to eq(rental.total_price_cents / 100.0)
    end

    it "#mark_returned! sets return fields and status" do
      rental.mark_returned!
      expect(rental.reload.order_status).to eq("returned")
      expect(rental.return_date).to eq(Date.current)
      expect(rental.returned_at).to be_present
    end

    it "#email_titles lists unique movie titles" do
      rental_with_movie = create(:rental, user:)
      create(:rental_item, rental: rental_with_movie, copy:)
      expect(rental_with_movie.email_titles).to include("The Matrix")
    end

    it "#order_titles includes title + format" do
      rental_with_movie = create(:rental, user:)
      create(:rental_item, rental: rental_with_movie, copy:)
      expect(rental_with_movie.order_titles).to include("The Matrix (DVD)")
    end
  end
end
