# Preview all emails at http://localhost:3000/rails/mailers/receipt_mailer_mailer
class ReceiptMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/receipt_mailer_mailer/receipt
  def receipt
    ReceiptMailer.receipt
  end

end
