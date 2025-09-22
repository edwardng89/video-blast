# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new(role: "user")

    if user.super_admin?
      can :manage, :all

    elsif user.admin?
      can :manage, [Video, Actor, Movie]
      can :read, :all
      cannot :manage, User
      cannot :manage, Order

    else
      # regular "user"
      can :read, Movie           # they may see Movie
      can :access, :lookups      # they may see the Lookups menu

      # no Actors / Genres / Rentals menu visibility:
      can :read, Actor
      can :read, Genre
      cannot :read, Rental

      # example order/customer limits (optional)
      # can [:read, :create], Order
      # cannot [:update, :destroy], Order

      # never manage users
      cannot :manage, User
    end
  end
end
