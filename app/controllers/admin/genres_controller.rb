# app/controllers/admin/genres_controller.rb
class Admin::GenresController < AdminController
  load_and_authorize_resource
  respond_to :html

  def index
    @title = "Genres"
    @genres = Genre.all
    @genres = @genres.search(params[:q])
    if params[:active].present?
      flag = ActiveModel::Type::Boolean.new.cast(params[:active])
      @genres = @genres.where(active: flag)
    end
    @genres = @genres.in_order.page(params[:page]).per(params[:per_page].presence || 25)
  end

  def new;   @title = "New Genre";  end
  def edit;  @title = "Edit #{@genre.name}"; end

  def create
    if @genre.save
      redirect_to admin_genres_path, notice: "Genre created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @genre.update(genre_params)
      redirect_to admin_genres_path, notice: "Genre updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @genre.destroy!
    redirect_to admin_genres_path, notice: "Genre deleted."
  end

  private
  def genre_params
    params.require(:genre).permit(:name, :active)
  end
end
