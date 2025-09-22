class SendReceiptJob < ApplicationJob
  queue_as :mailers

  def perform(rental_id)
    ReceiptMailer.receipt(rental_id).deliver_now
  end
end
