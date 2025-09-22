class Admin::DashboardController < AdminController
  skip_authorization_check only: :index
  def index
    @users = User.all
  end
end
