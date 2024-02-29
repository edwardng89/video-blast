class Tempest::MovieGenresController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'sort_order'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :movie_genres, :movie_genre

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Movie Genres'

    @movie_genres = apply_scopes(@movie_genres.includes(:genre, :movie))
    respond_with(@movie_genres) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @movie_genres = @movie_genres.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:movie_genres])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @movie_genres = MovieGenre.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @movie_genres = @movie_genres
                        .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @movie_genres.compact
      end
      format.js do
        @movie_genres = @movie_genres.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:movie_genres])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      # -- index_formats_ends --
    end
  end

  def show
    @title = @movie_genre

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Movie Genre'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@movie_genre}"

    respond_to do |format|
      if @movie_genre.save
        format.html do
          if request.xhr?
            row_partial = movie_genre_params[:alt_list].present? ? movie_genre_params[:alt_list] : 'movie_genre'
            render partial: row_partial, locals: { "#{row_partial}": @movie_genre }, status: 200
          else

            redirect_to edit_admin_movie_genre_path(@movie_genre)

          end
        end
        format.json do
          render json: { 'record_id': @movie_genre&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Movie Genre'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @movie_genre&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@movie_genre}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@movie_genre}"

    respond_to do |format|
      if @movie_genre.update(movie_genre_params)
        format.html do
          if request.xhr?
            row_partial = movie_genre_params[:alt_list].present? ? movie_genre_params[:alt_list] : 'movie_genre'
            render partial: row_partial, locals: { "#{row_partial}": @movie_genre }, status: 200
          else

            redirect_to edit_admin_movie_genre_path(@movie_genre), notice: 'Movie Genre was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @movie_genre&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@movie_genre}"
            render action: :edit
          end
        end
        format.json { render json: @movie_genre.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@movie_genre, admin_movie_genres_path)
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

  def movie_genre_params
    full_attributes = %i[
      genre_id
      movie_id
      sort_order
      alt_list
    ]

    params.require(:movie_genre)
          .permit(*strong_accessible_params(@movie_genre,
                                            MovieGenre,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
