##
# Helper methods for checking attribute access
module AttributeAccessHelper
  ##
  # Can the current user access the passed attribute at all
  #
  # @param attribute (Symbol or String)
  # @return (Boolean)
  def can_access_attribute?(attribute)
    return true unless @combined_attributes&.any?

    attribute = attribute.to_sym
    @combined_attributes.include?(attribute)
  end

  ##
  # Simple opposite of above
  #
  # @param attribute (Symbol or String)
  # @return (Boolean)
  def cannot_access_attribute?(attribute)
    !can_access_attribute?(attribute)
  end

  ##
  # Can the current user modify (create or update based on context) the passed attribute at all
  #
  # @param attribute (Symbol or String)
  # @return (Boolean)
  def can_modify_attribute?(attribute)
    return true unless @cancancan_attributes&.any?

    attribute = attribute.to_sym
    @cancancan_attributes.include?(attribute)
  end

  ##
  # Simple opposite of above
  #
  # @param attribute (Symbol or String)
  # @return (Boolean)
  def cannot_modify_attribute?(attribute)
    !can_modify_attribute?(attribute)
  end
end
