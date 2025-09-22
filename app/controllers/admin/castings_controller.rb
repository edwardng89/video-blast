class Admin::CastingsController < AdminController
    before_action :set_movie
    before_action :set_casting, only: [:edit, :update, :destroy]
    # Skip check authorization
    skip_authorization_check
    # Cancancan setup for resource initialisation
    load_and_authorize_resource
    
    # app/controllers/admin/castings_controller.rb
    def index
        @movie = Movie.find(params[:movie_id])
        @castings = @movie.castings.includes(:actor)
    end
    
    def new
        @casting = @movie.castings.build
        #@casting.build_actor   # optional, allows inline new actor
    end

    def create
        @casting = @movie.castings.new(casting_params)
        if @casting.save
            respond_to do |f|
                f.turbo_stream
                f.html { redirect_to edit_admin_movie_path(@movie), notice: "Added to cast." }
        end

        else
            render :new, status: :unprocessable_entity
        end
    end

    # app/controllers/admin/movies_controller.rb
    def edit
        @casting.build_actor unless @casting.actor
    end


    def update
        if @casting.update(casting_params)
            respond_to do |f|
                f.turbo_stream
                f.html { redirect_to edit_admin_movie_path(@movie), notice: "Updated." }
        end
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @casting.destroy
        respond_to do |f|
            f.turbo_stream
            f.html { redirect_to edit_admin_movie_path(@movie), notice: "Removed from cast." }
        end
    end

    private

    def set_movie   ; @movie   = Movie.find(params[:movie_id]) end
    def set_casting ; @casting = @movie.castings.find(params[:id]) end

    def casting_params
        params.require(:casting).permit(:actor_id, actor_attributes: [:first_name, :last_name])
    end

    
end
