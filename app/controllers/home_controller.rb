class HomeController < ApplicationController
  layout "public"
  def index
    scope = Movie.order(released_on: :desc)  # recent first

    @movies = Movie
      .includes(:genres, castings: :actor) # for names on the card
      .with_attached_cover                # ActiveStorage eager load
      .order(released_on: :desc, created_at: :desc)
      .page(params[:page]).per(12)

    if user_signed_in?
      rented_movie_ids = current_user.rentals
                                     .joins(copies: :movie)
                                     .pluck("movies.id")
      scope = scope.where.not(id: rented_movie_ids)
    end

    @videos = scope.order("RANDOM()").limit(5)
  end
end
