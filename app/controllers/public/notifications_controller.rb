# app/controllers/public/notifications_controller.rb
class Public::NotificationsController < ApplicationController
  layout "public"
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.includes(:movie).order(created_at: :desc)
  end

  def create
    @movie  = Movie.find(params[:movie_id])
    @format = params[:format].to_s

    @notification = current_user.notifications.find_or_initialize_by(movie: @movie, format: @format)

    if @notification.persisted?
      flash.now[:notice] = "You’re already on the waitlist."
    elsif @notification.save
      flash.now[:notice] = "We’ll email you when it’s back in stock."
    else
      flash.now[:alert] = @notification.errors.full_messages.to_sentence
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: public_movie_path(@movie) }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @movie  = @notification.movie
    @format = @notification.format
    @notification.destroy

    flash.now[:notice] = "Removed from waitlist."

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: public_notifications_path }
    end
  end
end
