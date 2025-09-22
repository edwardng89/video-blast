# app/jobs/overdue_notifier_job.rb
class OverdueNotifierJob < ApplicationJob
  queue_as :mailers

  def perform(run_date_str = Date.current.to_s)
    today = Date.parse(run_date_str)

    # Gentle: send if overdue AND (never sent OR last sent before today)
    gentle_scope = Rental.where(returned_at: nil).where.not(order_status: "returned")
                         .where("due_date < ?", today)
                         .where("overdue_notice_sent_at IS NULL OR DATE(overdue_notice_sent_at) < ?", today)

    # Escalation: send once if 3+ days overdue and not escalated yet
    escalation_scope = Rental.where(returned_at: nil).where.not(order_status: "returned")
                             .where("due_date < ?", today - 2.days)
                             .where(overdue_escalation_sent_at: nil)

    send_grouped(rentals_scope: gentle_scope.includes(:user, copies: :movie),
                 mailer_method: :gentle_reminder, stamp_attr: :overdue_notice_sent_at)

    send_grouped(rentals_scope: escalation_scope.includes(:user, copies: :movie),
                 mailer_method: :escalation, stamp_attr: :overdue_escalation_sent_at)
  end

  private

  def send_grouped(rentals_scope:, mailer_method:, stamp_attr:)
    rentals_scope.in_batches(of: 100) do |batch|
      batch.to_a.group_by(&:user).each do |user, rentals|
        next if user.blank? || user.email.blank?
        OverdueMailer.public_send(mailer_method, user: user, rentals: rentals).deliver_now
        Rental.where(id: rentals.map(&:id)).update_all(stamp_attr => Time.current)
      end
    end
  end
end
