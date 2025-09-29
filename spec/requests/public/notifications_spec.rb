require 'rails_helper'

RSpec.describe "Public::Notifications", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/public/notifications/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/public/notifications/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/public/notifications/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
