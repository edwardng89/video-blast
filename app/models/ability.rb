# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    # guest user (not logged in)
    user ||= User.new

    # Normalize role checks (works whether you use role string or boolean admin flag)
    role = (user.respond_to?(:role) && user.role).to_s

    if role == "super_admin" || (user.respond_to?(:super_admin?) && user.super_admin?)
      can :manage, :all

    elsif role == "admin" || (user.respond_to?(:admin?) && user.admin?)
      # Admins can manage core catalog + rentals
      can :manage, [Movie, Actor, Copy, Genre, Rental, Casting]

      # But do NOT manage users (adjust if you want admins to manage users)
      cannot :manage, User

      # Read everything else
      can :read, :all

    else
      # Regular user / guest
      can :read, Movie
      can :read, Genre
      can :read, Actor

      # Allow users to read their own rentals if you expose that (optional):
      # can :read, Rental, user_id: user.id

      # Block access to admin-only resources
      cannot :manage, User
      cannot :manage, Rental
      cannot :manage, [Copy, Casting]
    end
  end
end
