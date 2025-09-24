# app/controllers/public/movies_controller.rb
class Public::MoviesController < ApplicationController
  layout "public"

  def index
    @q              = params[:q].to_s.strip
    @genre_id       = params[:genre_id].presence
    @content_rating = params[:content_rating].presence
    @rating_min     = params[:rating_min].presence
    @sort           = params[:sort].presence

    # Base scope with AVG computed and exposed as avg_stars
    scope = Movie
              .preload(:genres, cover_attachment: :blob)
              .left_joins(:ratings)
              .select('movies.*, AVG(ratings.stars) AS avg_stars')
              .group('movies.id')

    # Text search
    if @q.present?
      s = "%#{@q.downcase}%"
      scope = scope.where("LOWER(movies.title) LIKE :s OR LOWER(movies.description) LIKE :s", s: s)
    end

    # Other filters
    scope = scope.joins(:genres).where(genres: { id: @genre_id }) if @genre_id
    scope = scope.where(content_rating: @content_rating) if @content_rating

    # Rating filter: treat NULL average as 0 so unrated movies are excluded when selecting 1+..5+
    if @rating_min && @rating_min.to_i.positive?
      scope = scope.having("COALESCE(AVG(ratings.stars), 0) >= ?", @rating_min.to_i)
    end

    # Portable ordering (works on Postgres & MySQL)
    # Emulate NULLS LAST/NULLS FIRST using CASE
    order_nulls_last_desc = Arel.sql("CASE WHEN avg_stars IS NULL THEN 1 ELSE 0 END, avg_stars DESC, movies.created_at DESC")
    order_nulls_last_asc  = Arel.sql("CASE WHEN avg_stars IS NULL THEN 1 ELSE 0 END, avg_stars ASC, movies.created_at DESC")

    scope =
      case @sort
      when "rating_desc"
        scope.reorder(order_nulls_last_desc)
      when "rating_asc"
        scope.reorder(order_nulls_last_asc)
      else
        scope.reorder("movies.created_at DESC") # important: use reorder, not order
      end

    @movies = scope.page(params[:page]).per(12)

    if turbo_frame_request?
      render partial: "public/movies/list", locals: { movies: @movies }
    else
      render :index
    end
  end

  def show
    @movie = Movie
               .preload(:genres, :copies, { castings: :actor }, cover_attachment: :blob)
               .find(params[:id])

    @format_stats = @movie.copies.group_by(&:copy_format).transform_values do |arr|
      {
        total: arr.size,
        available: arr.count { |c| c.status == "available" },
        price_cents: arr.map(&:rental_cost).compact.min
      }
    end

    @cast = @movie.castings.map(&:actor).compact

    @recommended = Movie
                     .preload(:genres, cover_attachment: :blob)
                     .joins(:genres)
                     .where(genres: { id: @movie.genre_ids })
                     .where.not(id: @movie.id)
                     .distinct
                     .order(Arel.sql("released_on DESC NULLS LAST, movies.created_at DESC"))
                     .limit(6)

    if @recommended.blank?
      @recommended = Movie
                       .with_attached_cover
                       .includes(:genres)
                       .where.not(id: @movie.id)
                       .order(Arel.sql("released_on DESC NULLS LAST, movies.created_at DESC"))
                       .limit(6)
    end

    if user_signed_in?
      rented_ids = Rental
                     .where(user_id: current_user.id)
                     .joins(rental_items: { copy: :movie })
                     .distinct
                     .pluck('movies.id')
      @recommended = @recommended.where.not(id: rented_ids) if rented_ids.any?
    end
  end
end
