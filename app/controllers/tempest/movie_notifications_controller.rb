class Tempest::MovieNotificationsController < AdminController
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource :user
  load_and_authorize_resource through: [:user], shallow: true

  respond_to :html
  has_scope :query

  decorates_assigned :movie_notifications, :movie_notification

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    @title = 'Notification Requests' if @user
    index_setup
    @title ||= 'Movie Notifications'

    @movie_notifications = apply_scopes(@movie_notifications.includes(:movie_copy))
    respond_with(@movie_notifications) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @movie_notifications = @movie_notifications.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@user, :movie_notifications])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @movie_notifications = MovieNotification.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @movie_notifications = @movie_notifications
                               .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @movie_notifications.compact
      end
      format.js do
        @movie_notifications = @movie_notifications.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@user, :movie_notifications])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @movie_notifications
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @movie_notification

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Movie Notification'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@movie_notification}"

    respond_to do |format|
      if @movie_notification.save
        format.html do
          if request.xhr?
            row_partial = movie_notification_params[:alt_list].present? ? movie_notification_params[:alt_list] : 'movie_notification'
            render partial: row_partial, locals: { "#{row_partial}": @movie_notification }, status: 200
          else

            redirect_to edit_admin_movie_notification_path(@movie_notification)

          end
        end
        format.json do
          render json: { 'record_id': @movie_notification&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Movie Notification'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @movie_notification&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@movie_notification}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@movie_notification}"

    respond_to do |format|
      if @movie_notification.update(movie_notification_params)
        format.html do
          if request.xhr?
            row_partial = movie_notification_params[:alt_list].present? ? movie_notification_params[:alt_list] : 'movie_notification'
            render partial: row_partial, locals: { "#{row_partial}": @movie_notification }, status: 200
          else

            redirect_to edit_admin_movie_notification_path(@movie_notification),
                        notice: 'Movie Notification was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @movie_notification&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@movie_notification}"
            render action: :edit
          end
        end
        format.json { render json: @movie_notification.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@movie_notification, admin_movie_notifications_path)
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
    return unless @user

    @allow_create = false
    @full_edit_create = false
    @default_limit = 25
    @allow_filter = true
    @pdf_button = false
    @copy_button = false
    @csv_button = false
    @xls_button = false
    @print_button = false
    @icon = ''

    ## nested model setup ends ##
  end

  def movie_notification_params
    full_attributes = %i[
      canceled_on
      movie_copy_id
      requested_on
      user_id
      alt_list
    ]

    params.require(:movie_notification)
          .permit(*strong_accessible_params(@movie_notification,
                                            MovieNotification,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
