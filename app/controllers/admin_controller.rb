##
# Base Level controller
class AdminController < Tempest::AdminController
    def index
    @users = User.order(:first_name)
  end

  # ⬇️ Add this action
  def export_pdf
    @users = User.order(:first_name)

    require 'prawn'
    pdf = Prawn::Document.new(page_size: 'A4', margin: 36)
    pdf.text "Users", size: 18, style: :bold
    pdf.move_down 10

    headers = %w[FirstName LastName Suburb State Gender Email Admin Active]
    rows = @users.map do |u|
      [
        u.first_name,
        u.last_name,
        u.suburb,
        u.state,
        u.gender,
        u.email,
        (u.respond_to?(:admin?)  ? (u.admin?  ? "Yes" : "No") : (u.admin  ? "Yes" : "No")),
        (u.respond_to?(:active?) ? (u.active? ? "Yes" : "No") : (u.active ? "Yes" : "No")),
      ]
    end

    pdf.table([headers] + rows, header: true)

    send_data pdf.render,
              filename: "users.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end
end
