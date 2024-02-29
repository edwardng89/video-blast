# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.role.present? && user.role.super_user?
      can :manage, :all
    else
      # If context switching enabled allows user to always switch back as we want
      can :stop_impersonating, User

      # FIXME: This is temporary until we define other actions within the Access Permissions interface
      # non_crud_actions = Rails.application.routes.routes.map do |route|
      #   route.defaults[:action]&.to_sym unless route.defaults[:action].in?(%w[index show new create edit update destroy])
      # end.compact.uniq.sort
      # FIXME: Flesh out with actions from the project, ideally automatically if time permits
      alt_lists = %i[]
      update_actions = %i[]
      alias_action(*alt_lists, to: :read)
      alias_action(*update_actions, to: :update)

      # Loop through the permissions of the user and build the can definitions from that
      user.permissions.each do |permission|
        # If we have attributes defined we need to split read and create/update
        @accessible_actions = permission.values[0]
        possible_actions = %i[read create update delete] # FIXME: this should be more central
        # Try splitting these so we end up with separate rules, may not work as combined since the
        # following doesn't return Ability.new(p).permitted_attributes(:update, Booking)
        setter_actions = %i[create update] # FIXME: ditto
        ability_rules = []
        if permission[:readable_attributes]&.any?
          popped_rule = @accessible_actions.delete(:read)
          if popped_rule
            ability_rules.push(popped_rule)
          else
            @accessible_actions = possible_actions.reject { |a| a == :read }
            ability_rules.push(:read)
          end
        end
        if permission[:settable_attributes]&.any?
          popped_rules = @accessible_actions.select { |a| setter_actions.include?(a) }
          @accessible_actions.reject! { |a| setter_actions.include?(a) }
          if popped_rules.any?
            ability_rules.push(popped_rules)
          else
            @accessible_actions = possible_actions.reject { |a| setter_actions.include?(a) }
            ability_rules.push(setter_actions)
          end
        end
        ability_rules.push(@accessible_actions)
        ability_rules.compact.reject(&:empty?).each do |ability_rule|
          params = [ability_rule, permission.keys[0].classify.safe_constantize]
          params.push({ id: user.send(permission[:restricted_by]) }) if permission[:restricted_by].present?
          if ability_rule == :read
            params.push(permission[:readable_attributes].map(&:to_sym)) if permission[:readable_attributes]&.any?
          elsif ability_rule == setter_actions
            params.push(permission[:settable_attributes].map(&:to_sym)) if permission[:settable_attributes]&.any?
          end

          # p "can #{params}" # useful if needing to debug roughly what the Ability file looks like
          can(*params)
        end
      end

    end
    # Define abilities for the user here. For example:
    #
    #   return unless user.present?
    #   can :manage, :all
    #   return unless user.admin?
    #   can :manage, :all
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, published: true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_check_abilities.md
  end
end
