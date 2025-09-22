class OverdueMailer < ApplicationMailer
  default from: "noreply@videoblast.example"

  def gentle_reminder(user:, rentals:)
    @user = user
    @rentals = rentals
    mail to: @user.email, subject: "Reminder: you have overdue rentals"
  end

  def escalation(user:, rentals:)
    @user = user
    @rentals = rentals
    mail to: @user.email, subject: "Overdue notice: late fees may apply"
  end
end
