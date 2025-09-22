# app/controllers/admin/rentals_controller.rb
class Admin::RentalsController < AdminController
  # Loads @user (parent) and @rental(s) through Cancancan
  load_and_authorize_resource :user,   class: "User"
  load_and_authorize_resource :rental, through: :user, class: "Rental"
  skip_authorization_check
  respond_to :html

  # GET /admin/users/:user_id/rentals
  def index
    @title = "All Rentals"
    @rentals = filtered_scope.page(params[:page]).per(params[:per_page].presence || 25)
  end

  # Rentals Due list (all users)
  # GET /admin/rentals/due
  def due
    @title = "Rentals Due"

    base = Rental.includes(:user, copies: :movie)
                 .order(due_date: :asc, "users.last_name": :asc)

    # Only ongoing + due today or overdue
    base = base.due_now unless params[:show_all].present?

    # Apply same filters as index
    df = safe_date(params[:date_from])
    dt = safe_date(params[:date_to])

    base = base.status_is(params[:order_status])
               .due_from(df)
               .due_to(dt)

    if params[:q].present?
      s = "%#{params[:q].to_s.downcase.strip}%"
      base = base.joins(copies: :movie)
                 .where("LOWER(movies.title) LIKE ? OR rentals.order_number ILIKE ?", s, s)
                 .distinct
    end

    @rentals = base.page(params[:page]).per(params[:per_page].presence || 25)
    render :due # you’ll create app/views/admin/rentals/due.html.erb
  end

  # GET /admin/users/:user_id/rentals/new
  def new
    @rental.rental_date ||= Date.current
  end

  # POST /admin/users/:user_id/rentals
  def create
    if @rental.update(rental_params)
      redirect_to edit_admin_user_path(@user), notice: "Order created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /admin/users/:user_id/rentals/:id/edit
  def edit; end

  # PATCH/PUT /admin/users/:user_id/rentals/:id
  def update
    if @rental.update(rental_params)
      redirect_to edit_admin_user_path(@user), notice: "Order updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/users/:user_id/rentals/:id
  def destroy
    @rental.destroy!
    redirect_to edit_admin_user_path(@user), notice: "Order deleted."
  end

  # PATCH /admin/users/:user_id/rentals/:id/mark_returned
  # app/controllers/admin/rentals_controller.rb
  def mark_returned
    @rental = Rental.find(params[:id])             # ensure this is set!
    @user   = @rental.user                         # you redirect with @user
    @rental.mark_returned!
    redirect_to request.referer.presence || admin_user_rentals_path(@user),
                notice: "Marked as returned."
  end

  private

  def rental_params
    params.require(:rental).permit(
      :rental_date,
      :due_date,
      :order_status,
      copy_ids: [] # multi-select via rental_items join
    )
  end

  def safe_date(val)
    return nil if val.blank?
    Date.parse(val) rescue nil
  end

  # Common filter logic for index
  def filtered_scope
    base = Rental.includes(:user, copies: :movie).order(due_date: :desc, user_id: :asc, order_number: :asc)

    df = safe_date(params[:date_from])
    dt = safe_date(params[:date_to])

    base = base.status_is(params[:order_status])
               .due_from(df)
               .due_to(dt)

    if params[:q].present?
      s = "%#{params[:q].to_s.downcase.strip}%"
      base = base.joins(copies: :movie)
                 .where("LOWER(movies.title) LIKE ? OR rentals.order_number ILIKE ?", s, s)
                 .distinct
    end

    base
  end
end
