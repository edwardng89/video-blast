class ReceiptMailer < ApplicationMailer
  default from: "noreply@videoblast.example"

  def receipt(rental_id)
    @rental = Rental.includes(rental_items: { copy: :movie }).find(rental_id)
    @user   = @rental.user

    pdf_html = ApplicationController.render(
      template: "receipt_mailer/show", # PDF template that uses locals: rental, user
      layout:   "pdf",
      locals:   { rental: @rental, user: @user }
    )

    pdf_file = WickedPdf.new.pdf_from_string(pdf_html)

    attachments["receipt-#{@rental.id}.pdf"] = {
      mime_type: "application/pdf",
      content:   pdf_file
    }

    mail(to: @user.email, subject: "Your VideoBlast Receipt ##{@rental.order_number}")
  end
end
