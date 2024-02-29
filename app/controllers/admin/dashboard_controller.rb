class Admin::DashboardController < AdminController
  skip_authorization_check only: :index
  def index; end
end
