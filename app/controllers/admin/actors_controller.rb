# app/controllers/admin/actors_controller.rb
class Admin::ActorsController < AdminController
  load_and_authorize_resource
  respond_to :html

  def index
    @title = "Actors"
    @actors = Actor.search(params[:q]).in_order.page(params[:page]).per(params[:per_page].presence || 25)
  end

  def new
    @actor = Actor.new
  end
  def edit; @title = "Edit #{@actor.first_name} #{@actor.last_name}"; end

  def create
    if @actor.save
      redirect_to admin_actors_path, notice: "Actor created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @actor.update(actor_params)
      redirect_to admin_actors_path, notice: "Actor updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
    @title = "Edit Actor"
    # Child list (movies) for the lower table
    base = @actor.respond_to?(:movies) ? @actor.movies : Movie.none
    @movies = base
                .yield_self { |r| params[:movies_q].present? ? r.where("LOWER(title) LIKE :s OR LOWER(description) LIKE :s", s: "%#{params[:movies_q].to_s.downcase.strip}%") : r }
                .order(released_on: :desc, title: :asc) # adjust to your column names
    @movies = @movies.page(params[:movies_page]).per(params[:per_page].presence || 25) if @movies.respond_to?(:page)
  end


  def destroy
    @actor.destroy!
    redirect_to admin_actors_path, notice: "Actor deleted."
  end

  private
  def actor_params
    params.require(:actor).permit(:first_name, :last_name, :gender, :active, :birth_date)
  end
end
