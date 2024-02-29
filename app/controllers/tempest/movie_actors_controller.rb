class Tempest::MovieActorsController < AdminController
  has_scope :in_order, as: :sort, allow_blank: true, default: 'sort_order'
  has_scope :reverse_order, type: :boolean
  load_and_authorize_resource :actor

  load_and_authorize_resource :movie
  load_and_authorize_resource through: %i[movie actor], shallow: true

  respond_to :html
  has_scope :query

  decorates_assigned :movie_actors, :movie_actor

  # filter_scopes_start_here
  # filter_scopes_end_here

  def index
    @title = 'Movies' if @actor
    @title = 'Cast' if @movie
    index_setup
    @title ||= 'Movie Actors'

    @movie_actors = apply_scopes(@movie_actors.includes(:actor, :movie))
    respond_with(@movie_actors) do |format|
      # index html group content starts here
      # index html group content ends here

      format.html do
        @movie_actors = @movie_actors.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@movie || @actor, :movie_actors])
        elsif request.xhr?
          render partial: 'table'
        end
      end
      format.json do
        return nil unless params[:text_output].to_s.include?('select2-code-identifier')

        @movie_actors = MovieActor.all.query(params[:query])
        text_output = if params[:text_output].to_s.include?('delete') ||
                         params[:text_output].to_s.include?('destroy')
                        'to_s'
                      else
                        params[:text_output].to_s.gsub('select2-code-identifier', '')
                      end
        identifier = text_output.presence || 'to_s'
        @movie_actors = @movie_actors
                        .map { |obj| { 'id': obj.id, 'text': obj&.decorate&.send(identifier) } }
        render json: @movie_actors.compact
      end
      format.js do
        @movie_actors = @movie_actors.page(params[:page]).per(@default_limit)
        if params[:commit] == 'Clear'
          redirect_to polymorphic_path([@movie || @actor, :movie_actors])
        else
          render 'index'
        end
      end
      # -- index_formats_starts --
      # -- index_formats_ends --
    end
  end

  def show
    @title = @movie_actor

    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  def new
    @alt_list = params[:alt_list]

    @title = 'New Movie Actor'
    return unless request.xhr?

    render partial: 'quick_edit_form'
  end

  def create
    @title = "Edit #{@movie_actor}"

    respond_to do |format|
      if @movie_actor.save
        format.html do
          if request.xhr?
            row_partial = movie_actor_params[:alt_list].present? ? movie_actor_params[:alt_list] : 'movie_actor'
            render partial: row_partial, locals: { "#{row_partial}": @movie_actor }, status: 200
          else

            redirect_to edit_admin_movie_actor_path(@movie_actor)

          end
        end
        format.json do
          render json: { 'record_id': @movie_actor&.id }
        end
      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = 'New Movie Actor'
            render action: :new
          end
        end

        format.json do
          render json: { 'record_id': @movie_actor&.id }
        end

      end
    end
  end

  def edit
    @title = "Edit #{@movie_actor}"
    @alt_list = params[:alt_list]
    return unless request.xhr?

    if params[:single_show_edit]
      render partial: 'form'
    else
      render partial: 'quick_edit_form'
    end
  end

  def update
    @title = "Edit #{@movie_actor}"

    respond_to do |format|
      if @movie_actor.update(movie_actor_params)
        format.html do
          if request.xhr?
            row_partial = movie_actor_params[:alt_list].present? ? movie_actor_params[:alt_list] : 'movie_actor'
            render partial: row_partial, locals: { "#{row_partial}": @movie_actor }, status: 200
          else

            redirect_to edit_admin_movie_actor_path(@movie_actor), notice: 'Movie Actor was successfully updated.'

          end
        end

        format.json do
          render json: { 'record_id': @movie_actor&.id }
        end

      else
        format.html do
          if request.xhr?
            render partial: 'quick_edit_form', status: 422
          else
            @title = "Edit #{@movie_actor}"
            render action: :edit
          end
        end
        format.json { render json: @movie_actor.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    destroy_common(@movie_actor, admin_movie_actors_path)
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
    if @actor
      @allow_create = true
      @full_edit_create = false
      @default_limit = 25
      @allow_filter = true
      @pdf_button = false
      @copy_button = false
      @csv_button = false
      @xls_button = false
      @print_button = false
      @icon = ''

    end
    return unless @movie

    @allow_create = true
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

  def movie_actor_params
    full_attributes = %i[
      actor_id
      movie_id
      sort_order
      alt_list
    ]

    params.require(:movie_actor)
          .permit(*strong_accessible_params(@movie_actor,
                                            MovieActor,
                                            full_attributes))
  end

  # -- private_actions_starts --
  # -- private_actions_ends --
end
