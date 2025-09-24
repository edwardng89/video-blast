require 'rails_helper'

RSpec.describe "Public::Orders", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/public/orders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/public/orders/create"
      expect(response).to have_http_status(:success)
    end
  end

end
