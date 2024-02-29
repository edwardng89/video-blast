class Tempest::MoviesController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'title'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource
  respond_to :html
  has_scope :query

  decorates_assigned :movies, :movie

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    index_setup
    @title ||= 'Movies'

    @movies = apply_scopes(@movies)
    respond_with(@movies) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @movies = @movies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:movies])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @movies = Movie.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @movies = @movies
                  .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @movies.compact
      end
      format.js do
        @movies = @movies.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([:movies])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      format.xls do
        render xls: @movies
      end
      # -- index_formats_ends --
    end
  end

  def show
    @title = @movie

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Movie'
  end

  def create
    @title = "Edit #{@movie}"

    respond_to do |format|
      if @movie.save
        format.html do
          redirect_to edit_admin_movie_path(@movie)
        end

        format.json do
          render json: { 'record_id': @movie&.id }
        end

      else
        format.html do
          @title = 'New Movie'
          render action: :new
        end
      end
    end
  end

  def edit
    @title = "Edit #{@movie}"
    render partial: 'form' if request.xhr? && params[:single_show_edit]
  end

  def update
    @title = "Edit #{@movie}"

    respond_to do |format|
      if @movie.update(movie_params)
        format.html do
          redirect_to edit_admin_movie_path(@movie), notice: 'Movie was successfully updated.'
        end
      else
        format.html do
          @title = "Edit #{@movie}"
          render action: :edit
        end
      end
    end
  end

  def destroy
    destroy_common(@movie, admin_movies_path)
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

  def movie_params
    full_attributes = [
      :active,
      :content_rating,
      :cover,
      :remove_cover,
      :description,
      { genre_ids: [] },
      { movie_actor_ids: [] },
      { movie_copy_ids: [] },
      { movie_genre_ids: [] },
      :released_on,
      :title,
      { user_rating_ids: [] },
      :alt_list
    ]

    params.require(:movie)
          .permit(*strong_accessible_params(@movie,
                                            Movie,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
