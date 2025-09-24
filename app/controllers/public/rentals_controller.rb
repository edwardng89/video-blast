class Public::RentalsController < ApplicationController
  layout "public"
  before_action :authenticate_user!

  def create
    cart = session[:cart] || {}
    return redirect_to public_cart_path, alert: "Your cart is empty." if cart.blank?

    copies = Copy.where(id: cart.keys)
    today  = Time.zone.today

    rental = current_user.rentals.build(
      order_number: "R#{today.strftime('%Y%m%d')}#{SecureRandom.hex(4).upcase}",
      order_status: "ongoing",
      rental_date:  today,                 # <-- NOT NULL column
      due_date:     today + 7.days         # <-- persist due date so admin can show it
    )
    rental.save!

    Rental.transaction do
      copies.each do |copy|
        qty = cart[copy.id.to_s].to_i
        next if qty <= 0
        # if you added quantity column:
        rental.rental_items.create!(copy: copy, quantity: qty)
        # if you DIDN'T add quantity, you'd need qty.times { rental.rental_items.create!(copy: copy) }
        # but that will hit your unique index—so quantity column is recommended.
      end
    end

    session.delete(:cart)
    redirect_to public_rental_path(rental), notice: "Rental created!"
  end

  # app/controllers/public/rentals_controller.rb
  def show
    @rental = current_user.rentals.includes(rental_items: { copy: :movie }).find(params[:id])

    @items = @rental.rental_items.map do |ri|
      copy = ri.copy
      unit = copy.rental_cost.to_i
      {
        movie: copy.movie,
        copy: copy,
        quantity: ri.quantity,
        unit_price_cents: unit,
        subtotal_cents: unit * ri.quantity
      }
    end
    @total_cents = @items.sum { |it| it[:subtotal_cents] }
  end

end
