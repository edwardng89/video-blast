class Tempest::UserRatingsController < AdminController
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :user_ratings, :user_rating

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'User Ratings'

    @user_ratings = apply_scopes(@user_ratings.includes(:movie))
    respond_with(@user_ratings) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @user_ratings = @user_ratings.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:user_ratings])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @user_ratings = UserRating.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @user_ratings = @user_ratings
                        .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @user_ratings.compact
      end
      format.js do
        @user_ratings = @user_ratings.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:user_ratings])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @user_ratings
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @user_rating

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New User Rating'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@user_rating}"

    respond_to do |format|
      if @user_rating.save
        format.html do
          if request.xhr?
            row_partial = user_rating_params[:alt_list].present? ? user_rating_params[:alt_list] : 'user_rating'
            render partial: row_partial, locals: { "#{row_partial}": @user_rating }, status: 200
          else

            redirect_to edit_admin_user_rating_path(@user_rating)

          end
        end
        format.json do
          render json: { 'record_id': @user_rating&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New User Rating'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @user_rating&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@user_rating}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@user_rating}"

    respond_to do |format|
      if @user_rating.update(user_rating_params)
        format.html do
          if request.xhr?
            row_partial = user_rating_params[:alt_list].present? ? user_rating_params[:alt_list] : 'user_rating'
            render partial: row_partial, locals: { "#{row_partial}": @user_rating }, status: 200
          else

            redirect_to edit_admin_user_rating_path(@user_rating), notice: 'User Rating was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @user_rating&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@user_rating}"
            render action: :edit
          end
        end
        format.json { render json: @user_rating.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@user_rating, admin_user_ratings_path)
  end

  # -- custom_actions_starts --
  # -- custom_actions_ends --

  private

  def index_setup
    @allow_create = true
    @full_edit_create = false
    @default_limit = 25
    @allow_filter = false
    @pdf_button = false
    @copy_button = false
    @csv_button = false
    @xls_button = true
    @print_button = false
    @main_list_screen = true
    @icon = ''
    @show_buttons = @pdf_button || @copy_button || @csv_button || @xls_button || @print_button

    ## nested model setup starts ##
    ## nested model setup ends ##
  end

  def user_rating_params
    full_attributes = %i[
      movie_id
      rating
      user
      alt_list
    ]

    params.require(:user_rating)
          .permit(*strong_accessible_params(@user_rating,
                                            UserRating,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
