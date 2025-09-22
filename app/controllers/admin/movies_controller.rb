# app/controllers/admin/movies_controller.rb
class Admin::MoviesController < AdminController
  # Use CanCanCan to load @movie/@movies; remove skip_authorization_check so rules apply
  load_and_authorize_resource

  # GET /admin/movies
  def index
    index_setup
    @title ||= 'Movies'

    # Start from CanCan's scope if you prefer:
    @movies = @movies || Movie.all

    @movies = @movies.search(params[:search]) if params[:search].present?
    @movies = @movies.in_order(params[:sort])  # ensure this always returns a relation

    if params[:active].present?
      active_flag = ActiveModel::Type::Boolean.new.cast(params[:active])
      @movies = @movies.where(active: active_flag)
    end

    @movies = @movies.page(params[:page]).per(10)
  end

  # GET /admin/movies/:id/edit
  def edit
    @copies   = @movie.copies.order(created_at: :desc)
    @castings = @movie.castings.includes(:actor).page(params[:page]).per(10)
    @title    = "Edit Movie"
  end

  # POST /admin/movies
  def create
    @movie = Movie.new(movie_params) # build from params so :cover attaches

    respond_to do |format|
      if @movie.save
        format.html { redirect_to edit_admin_movie_path(@movie) }
        format.json { render json: { record_id: @movie.id } }
      else
        format.html do
          @title = 'New Movie'
          render :new
        end
      end
    end
  end

  # GET /admin/movies/:id
  def show
    @title = @movie
    return unless request.xhr?

    # When javascript request made, display show modal or show screen partial
    if params[:single_show_edit]
      render partial: 'show'
    else
      render partial: 'modal_show'
    end
  end

  # PATCH/PUT /admin/movies/:id
  def update
    respond_to do |f|
      if @movie.update(movie_params)
        f.turbo_stream
        f.html { redirect_to edit_admin_movie_path(@movie), notice: "Movie updated." }
      else
        f.turbo_stream { render :edit, status: :unprocessable_entity }
        f.html        { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/movies/:id
  def destroy
    destroy_common(@movie, admin_movies_path)
  end

  private

  def index_setup
    @pdf_button   = true
    @copy_button  = true
    @csv_button   = true
    @xls_button   = true
    @print_button = true
    @show_buttons = @pdf_button || @copy_button || @csv_button || @xls_button || @print_button
    @allow_create = true
  end

  # Strong params for Movie ONLY (copies/castings have their own controllers)
  def movie_params
    full_attributes = [
      :active,
      :content_rating,
      :cover,
      :description,
      :released_on,
      :title,
      :alt_list,
      :creator_id,
      :updater_id,
      genre_ids: [],
      castings_attributes: [:id, :actor_id, :role_name, :_destroy, { actor_attributes: [:id, :name] }]
    ]

    params.require(:movie)
          .permit(*strong_accessible_params(@movie, Movie, full_attributes))
  end
end
