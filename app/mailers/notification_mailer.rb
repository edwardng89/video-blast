class NotificationMailer < ApplicationMailer
  def purchase_success(notification)
    @user = notification.user
    @movie = notification.movie
    mail(to: @user.email, subject: "You successfully rented #{@movie.title}!")
  end
end
