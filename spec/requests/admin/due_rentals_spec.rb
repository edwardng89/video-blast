require 'rails_helper'

RSpec.describe "Admin::DueRentals", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/due_rentals/index"
      expect(response).to have_http_status(:success)
    end
  end

end
