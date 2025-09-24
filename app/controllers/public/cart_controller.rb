# app/controllers/public/cart_controller.rb
class Public::CartController < ApplicationController
  layout "public"

  def show
    cart = session[:cart] || {}                               # {"7"=>"2", "4"=>"1"}
    copies = Copy.includes(:movie).where(id: cart.keys)
    by_id  = copies.index_by { |c| c.id.to_s }

    @items = cart.map do |copy_id, qty|
      copy = by_id[copy_id.to_s]
      next unless copy
      q = qty.to_i
      unit_cents = copy.rental_cost.to_i                      # already cents
      {
        copy: copy,
        movie: copy.movie,
        quantity: q,
        unit_price_cents: unit_cents,
        subtotal_cents: unit_cents * q
      }
    end.compact

    @total_cents = @items.sum { |it| it[:subtotal_cents] }
  end

  def add
    copy_id = params[:copy_id].to_s
    qty     = [params[:quantity].to_i, 1].max
    session[:cart] ||= {}
    session[:cart][copy_id] = session[:cart][copy_id].to_i + qty
    redirect_back fallback_location: public_movies_path, notice: "Added to cart."
  end

  def update
    raw = params.fetch(:items, {})
    items = raw.is_a?(ActionController::Parameters) ? raw.permit!.to_h : raw
    session[:cart] = items.each_with_object({}) do |(copy_id, qty), h|
      q = qty.to_i
      h[copy_id.to_s] = q if q > 0
    end
    redirect_to public_cart_path, notice: "Cart updated."
  end

  def clear
    session.delete(:cart)
    redirect_to public_cart_path, notice: "Cart cleared."
  end
end
