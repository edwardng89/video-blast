class Tempest::UsersController < AdminController

  # Define scopes that are applied through `apply_scopes` within controller action
  has_scope :in_order, as: :sort, allow_blank: true, default: User.default_sort_option
  has_scope :reverse_order, type: :boolean
  has_scope :query
  
  # Cancancan setup for resource initialisation
  load_and_authorize_resource

  # Draper decorator setup applied to object
  decorates_assigned :users, :user

  # handle html requests
  respond_to :html

  def index

    # sets up the default theme variables that control display on the screen, e.g. pagination count
    index_setup

    # name of the model to display on view screens
    @title ||= 'Users'
    # apply_scopes adds any filter defined in the controller
    @users = apply_scopes(User.all)
    # Apply search if the user typed into the search box
    @users = User.search(params[:search]) if params[:search].present?
    # Apply sorting and display users list base on order or show all
    @users = (@users || User.all).in_order(params[:sort])

    
    # Filter by active/inactive if that dropdown is used
    if params[:active].present?
      # params[:active] comes in as "true"/"false" strings
      active_flag = ActiveModel::Type::Boolean.new.cast(params[:active])
      @users = @users.where(active: active_flag)
    end

    @users = @users.page(params[:page])
    
    respond_with(@users) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        # Set up pagination for the model collection
        # FIXME replace with collection name of the model
        @users = @users.page(params[:page]).per(@default_limit)

        # clears saved params for filters in redis
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:users])
        elsif request.xhr?
          # for modal display, display just table partial when request made through Javascript
          render partial: 'table'
        end
      end

      # Json return of index
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @users = User.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @users = @users
                 .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @users.compact
      end

      # Javascript handling for index action
      format.js do
        @users = @users.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:users])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.csv { send_data @users.to_csv, filename: "users-#{Date.today}.csv" }
      format.xls { send_data @users.to_xls, filename: "users-#{Date.today}.xls" }
      
      # -- index_formats_ends --
    end
  end

  def show
    @title = @user

    return unless request.xhr?

    # When javascript request made, display show modal or show screen partial
    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New User'
  end

  def create
    @title = "Edit #{@user}"

    respond_to do |format|
      # @user.skip_password_validation = true
      if @user.save

        # devise inviteable for adding an admin user to the system
        @user.invite!(current_user)
        format.html do
          redirect_to edit_admin_user_path(@user)
        end

        format.json do
          render json: { 'record_id': @user&.id }
        end

      else
        format.html do
          @title = 'New User'
          render action: :new
        end
      end
    end
  end

  def edit
  @user  = User.find(params[:id])
  @title = "Edit #{@user}"

  @allow_create = true  # so the “Add New” button shows

  @status_filter = params[:status]
  @date_from     = params[:date_from]
  @date_to       = params[:date_to]

  scope = @user.rentals
  scope = scope.where(order_status: @status_filter) if @status_filter.present?
  scope = scope.where("rental_date >= ?", Date.strptime(@date_from, "%d/%m/%Y")) rescue scope if @date_from.present?
  scope = scope.where("rental_date <= ?", Date.strptime(@date_to, "%d/%m/%Y"))   rescue scope if @date_to.present?

  @rentals = scope.order(rental_date: :desc, created_at: :desc)
                  .includes(copies: :movie)  # NOTE: copies (plural) now

  per_page = (params[:per_page].presence || 25).to_i
  @rentals = @rentals.page(params[:page]).per(per_page) if @rentals.respond_to?(:page)

  render partial: 'form' if request.xhr? && params[:single_show_edit]
end




  def update
    @title = "Edit #{@user}"

    respond_to do |format|
      if @user.update(user_params)
        format.html do
          redirect_to edit_admin_user_path(@user), notice: 'User was successfully updated.'
        end
      else
        format.html do
          @title = "Edit #{@user}"
          render action: :edit
        end
      end
    end
  end

  def destroy
    # destory logic is common between all controllers, so call method
    destroy_common(@user, admin_users_path)
  end

  # -- custom_actions_starts --
  # -- custom_actions_ends --

  ##
  # reset password action
  def reset_password
    @user.reset_login_password
    redirect_to user_path(@user), notice: 'Password for user has been reset'
  end

  private

  def index_setup
    @allow_create = true
    @full_edit_create = true
    @default_limit = 25
    @allow_filter = true
    @pdf_button = true
    @copy_button = true
    @csv_button = true
    @xls_button = true
    @print_button = true
    @main_list_screen = true
    @icon = ''
    @show_buttons = @pdf_button || @copy_button || @csv_button || @xls_button || @print_button

    ## nested model setup starts ##
    ## nested model setup ends ##
  end

  def user_params
    full_attributes = [
      :active,
      :address_line_1,
      :address_line_2,
      :admin,
      :email,
      :first_name,
      :gender,
      :last_name,
      { movie_notification_ids: [] },
      { order_ids: [] },
      :password,
      :postcode,
      :role,
      :state,
      :suburb,
      { user_rating_ids: [] },
      :alt_list
    ]

    params.require(:user)
          .permit(*strong_accessible_params(@user,
                                            User,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # app/controllers/users_controller.rb
  
  # -- private_actions_ends --


end
