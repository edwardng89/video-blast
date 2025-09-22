# app/controllers/admin/copies_controller.rb
class Admin::CopiesController < AdminController
  before_action :set_movie
  before_action :set_copy, only: [:edit, :update, :destroy]

  # If you're NOT using CanCanCan rules yet, keep this:
  skip_authorization_check
  # If you ARE using CanCanCan, remove the line above and use this instead:
  # load_and_authorize_resource :copy, through: :movie

  # GET /admin/movies/:movie_id/copies
  def index
    @copies = @movie.copies.order(created_at: :desc)
  end

  # GET /admin/movies/:movie_id/copies/new
  def new
    @copy = @movie.copies.build
  end

  # POST /admin/movies/:movie_id/copies
  def create
  attrs = copy_params.to_h.symbolize_keys
  @copy = @movie.copies.build

  # Try assigning attributes one by one to find the offender
  attrs.each do |k, v|
    begin
      @copy.public_send("#{k}=", v)
    rescue => e
      Rails.logger.error("[Copies#create] FAILED on #{k} with value=#{v.inspect} (#{e.class}: #{e.message})")
      raise # re-raise so you see the stack trace now that we know the key
    end
  end

  if @copy.save
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_to edit_admin_movie_path(@movie), notice: "Copy added." }
    end
  else
    render :new, status: :unprocessable_entity
  end
end


  # GET /admin/movies/:movie_id/copies/:id/edit
  def edit
  end

  # PATCH/PUT /admin/movies/:movie_id/copies/:id
  def update
    if @copy.update(copy_params)
      respond_to do |f|
        f.turbo_stream
        f.html { redirect_to edit_admin_movie_path(@movie), notice: "Copy updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/movies/:movie_id/copies/:id
  def destroy
    @copy.destroy
    respond_to do |f|
      f.turbo_stream
      f.html { redirect_to edit_admin_movie_path(@movie), notice: "Copy removed." }
    end
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def set_copy
    @copy = @movie.copies.find(params[:id])
  end

  # Strong params aligned with your copies table:
  # :copy_format (string), :status (string), :no_of_copies (integer),
  # :active (boolean), :rental_cost (integer)
  def copy_params
    params.require(:copy).permit(:copy_format, :no_of_copies, :rental_cost, :status, :active, :rental_cost_dollars)
  end 


end
