class Tempest::GenresController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'sort_order'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :genres, :genre

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Genres'

    @genres = apply_scopes(@genres)
    respond_with(@genres) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @genres = @genres.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:genres])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @genres = Genre.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @genres = @genres
                  .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @genres.compact
      end
      format.js do
        @genres = @genres.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:genres])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      # -- index_formats_ends --
    end
  end

  def show
    @title = @genre

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Genre'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@genre}"

    respond_to do |format|
      if @genre.save
        format.html do
          if request.xhr?
            row_partial = genre_params[:alt_list].present? ? genre_params[:alt_list] : 'genre'
            render partial: row_partial, locals: { "#{row_partial}": @genre }, status: 200
          else

            redirect_to edit_admin_genre_path(@genre)

          end
        end
        format.json do
          render json: { 'record_id': @genre&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Genre'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @genre&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@genre}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@genre}"

    respond_to do |format|
      if @genre.update(genre_params)
        format.html do
          if request.xhr?
            row_partial = genre_params[:alt_list].present? ? genre_params[:alt_list] : 'genre'
            render partial: row_partial, locals: { "#{row_partial}": @genre }, status: 200
          else

            redirect_to edit_admin_genre_path(@genre), notice: 'Genre was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @genre&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@genre}"
            render action: :edit
          end
        end
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@genre, admin_genres_path)
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
    @xls_button = false
    @print_button = false
    @main_list_screen = true
    @icon = ''
    @show_buttons = @pdf_button || @copy_button || @csv_button || @xls_button || @print_button

    ## nested model setup starts ##
    ## nested model setup ends ##
  end

  def genre_params
    full_attributes = [
      :active,
      { movie_genre_ids: [] },
      { movie_ids: [] },
      :name,
      :sort_order,
      :alt_list
    ]

    params.require(:genre)
          .permit(*strong_accessible_params(@genre,
                                            Genre,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
