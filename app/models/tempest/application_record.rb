class Tempest::ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  include UserSortable
  include ActiveModel::Dirty

  ##
  # @!scope class
  # Super scope for searching enums
  # @param status_column (String) column being searched on
  # @param query_status (String) Status parameter for column
  # @return (Scope)
  scope :super_scope, lambda { |status_column, query_status|
    operator_regex = /(not-|and-|or-)/
    # If the status param passed through contains operational words then handle as combined
    if query_status.match?(operator_regex)
      value_parts = query_status.split(operator_regex).compact_blank
      operators, statuses = value_parts.partition { |value_part| value_part.match?(operator_regex) }
      statuses = statuses.map { |s| s.gsub(/-$/, '') }
      # If the operations are all the same and OR then we'll simplify the query
      if !operators.include?('and-') && [statuses.count, 0].include?(operators.count { |o| o == 'not-' })
        if operators.count { |o| o == 'not-' }.positive?
          where.not(status_column => statuses)
        else
          where(status_column => statuses)
        end
      else
        # FIXME: Don't expect ideal results when missing AND/OR because there is no bracketing
        sql_string = []
        last_status = nil
        value_parts.each_with_index do |status, i|
          next if status.match?(operator_regex)

          status_operators = value_parts[(last_status || 0)..(i - 1)] if i.positive?
          join_operator = case status_operators&.first
                          when 'and-'
                            'AND '
                          when 'or-'
                            'OR '
                          else
                            ''
                          end
          conditional_operator = status_operators&.last == 'not-' ? '<>' : '='
          sql_string << "#{join_operator}#{status_column} #{conditional_operator} ?"
          last_status = i + 1
        end
        where(sql_string.join(' '), *statuses)
      end
    elsif query_status.blank?
      nil
    else
      where(status_column => query_status)
    end
  }

  include ClassyEnum::ActiveRecord

  attr_accessor :alt_list

  ##
  # Retrieve the attributes from the model for display within the Access Permission interface
  # @param only_setters (Boolean) allow selecting only setter methods for display under Create/Update
  def self.access_attributes(only_setters = false)
    attrs = column_names.reject { |a| a == primary_key }.map { |a| a.gsub(/_id$/, '') }
    # Grab instance methods from only the direct model and the Tempest version
    inst_methods = (instance_methods(false) + "Tempest::#{name}".classify&.safe_constantize
                                                &.instance_methods(false)).map(&:to_s).uniq
    ends_with_eql = ->(m) { m.ends_with?('=') }
    # Keep an eye out here, we may need to include setters for has_many
    attrs += inst_methods.send(only_setters ? :select : :reject, &ends_with_eql)
    attrs += "#{name}Decorator".classify&.safe_constantize&.instance_methods&.map(&:to_s) unless only_setters
    # Only include those that start with an alpha character
    # Remove those that start with common method names
    attrs = attrs.select do |a|
      a.starts_with?(/[a-z]/) && !a.starts_with?('autosave_associated_records_for_') &&
        !a.starts_with?('validate_associated_records_for_')
    end
    # Remove the common methods that won't be included on screens from Tempest
    attrs -= %w[active_for_authentication? acts_like? applied_decorators as_json as_xls attributes blank?
                class class_eval clone context context= debugger devise_modules? decorated? decorated_with? deep_dup
                define_singleton_method destroy_without_paranoia devise_modules dup duplicable? encrypted_password enum_for
                eql? equal? extend freeze from_json from_xml frozen? gem h hash helpers html_safe? in? include_root_in_json
                include_root_in_json? inspect instance_eval instance_exec instance_of? instance_values
                instance_variable_defined? instance_variable_get instance_variable_names instance_variable_set
                instance_variables is_a? itself kind_of? l localize method method_missing methods model model_name nil?
                object object_id paranoia_column paranoia_column= paranoia_column? paranoia_sentinel_value
                paranoia_sentinel_value= paranoia_sentinel_value? presence
                presence_in present? pretty_inspect pretty_print pretty_print_cycle pretty_print_inspect
                pretty_print_instance_variables private_methods protected_methods public_method public_methods public_send
                read_attribute_for_serialization really_delete really_destroyed? remove_instance_variable require
                require_dependency respond_to? send serializable_hash singleton_class singleton_method singleton_method_added
                singleton_methods taint tainted? tap then to_enum to_gid to_gid_param to_global_id to_json to_model to_param
                to_partial_path to_query to_s to_sgid to_sgid_param to_signed_global_id to_xml to_yaml trap trust try try!
                untaint untrust untrusted? with_options yield_self]
    # Remove =, then unique and sort alphabetically
    attrs = attrs.map { |a| a.gsub(/=$/, '') }.uniq.sort
    attrs.map { |a| [a.titleize, a] }
  end
end
