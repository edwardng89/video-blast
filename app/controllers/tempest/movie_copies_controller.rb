class Tempest::MovieCopiesController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'format'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource :movie
  load_and_authorize_resource through: [:movie], shallow: true

  respond_to :html
  has_scope :query

  decorates_assigned :movie_copies, :movie_copy

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Movie Copies'

    @movie_copies = apply_scopes(@movie_copies)
    respond_with(@movie_copies) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @movie_copies = @movie_copies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@movie, :movie_copies])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @movie_copies = MovieCopy.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @movie_copies = @movie_copies
                        .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @movie_copies.compact
      end
      format.js do
        @movie_copies = @movie_copies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@movie, :movie_copies])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @movie_copies
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @movie_copy

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Movie Copy'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@movie_copy}"

    respond_to do |format|
      if @movie_copy.save
        format.html do
          if request.xhr?
            row_partial = movie_copy_params[:alt_list].present? ? movie_copy_params[:alt_list] : 'movie_copy'
            render partial: row_partial, locals: { "#{row_partial}": @movie_copy }, status: 200
          else

            redirect_to edit_admin_movie_copy_path(@movie_copy)

          end
        end
        format.json do
          render json: { 'record_id': @movie_copy&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Movie Copy'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @movie_copy&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@movie_copy}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@movie_copy}"

    respond_to do |format|
      if @movie_copy.update(movie_copy_params)
        format.html do
          if request.xhr?
            row_partial = movie_copy_params[:alt_list].present? ? movie_copy_params[:alt_list] : 'movie_copy'
            render partial: row_partial, locals: { "#{row_partial}": @movie_copy }, status: 200
          else

            redirect_to edit_admin_movie_copy_path(@movie_copy), notice: 'Movie Copy was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @movie_copy&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@movie_copy}"
            render action: :edit
          end
        end
        format.json { render json: @movie_copy.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@movie_copy, admin_movie_copies_path)
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
    return unless @movie

    @allow_create = true
    @full_edit_create = false
    @default_limit = 25
    @allow_filter = false
    @pdf_button = false
    @copy_button = false
    @csv_button = false
    @xls_button = false
    @print_button = false
    @icon = ''

    ## nested model setup ends ##
  end

  def movie_copy_params
    full_attributes = [
      :active,
      :copies,
      :format,
      :movie_id,
      { movie_notification_ids: [] },
      { order_movie_copy_ids: [] },
      :rental_price,
      :alt_list
    ]

    params.require(:movie_copy)
          .permit(*strong_accessible_params(@movie_copy,
                                            MovieCopy,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
