class ApplicationDecorator < Draper::Decorator
  ##
  # @return (String) The datetime of creation plus the #to_s value of the creator
  def created
    str = []
    str << object.created_at if object.respond_to?(:created_at) && object.created_at.present?

    if object.respond_to?(:creator) && object.creator
      str << 'by'
      str << object.creator
    end

    str.join(' ').strip.html_safe
  end

  ##
  # @return (String) The datetime of last update plus the #to_s value of the updater
  def updated
    str = []
    str << object.updated_at if object.respond_to?(:updated_at) && object.updated_at.present?

    if object.respond_to?(:updater) && object.updater
      str << 'by'
      str << object.updater
    end

    str.join(' ').strip.html_safe
  end

  def full_name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def given_names
    first_name << (middle_name.present? ? ', ' + middle_name : '')
  end

  ##
  # Friendly filename based on the class and any extras
  # @param classname [String]
  # @param extras [String]
  # @return (String)
  def self.xls_filename(classname, extras = nil)
    filename = "#{Date.current.to_formatted_s(:xls)}_#{classname}"
    filename << "_#{extras}" if extras
    filename
  end
end
