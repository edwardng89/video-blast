require 'rails_helper'

RSpec.describe "Public::Carts", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/public/cart/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /add" do
    it "returns http success" do
      get "/public/cart/add"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/public/cart/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /clear" do
    it "returns http success" do
      get "/public/cart/clear"
      expect(response).to have_http_status(:success)
    end
  end

end
