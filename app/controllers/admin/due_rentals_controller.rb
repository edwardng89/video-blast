class Admin::DueRentalsController < AdminController
  skip_authorization_check
  respond_to :html

  def index
    @title = "Rentals Due"

    scope = Rental.includes(:user).order(due_date: :asc)

    # Apply default only when show_all is NOT set
    unless ActiveModel::Type::Boolean.new.cast(params[:show_all])
      scope = scope.due_now  # your default scope
    end

    scope = scope.where(order_status: params[:status]) if params[:status].present?
    scope = scope.where("rental_date >= ?", Date.parse(params[:date_from])) if params[:date_from].present?
    scope = scope.where("rental_date <= ?", Date.parse(params[:date_to]))   if params[:date_to].present?

    if params[:q].present?
      q = "%#{params[:q].strip}%"
      scope = scope.where("order_number ILIKE :q OR order_titles ILIKE :q", q: q)
    end

    @rentals = scope.page(params[:page]).per(params[:per_page] || 25)
  end
end
