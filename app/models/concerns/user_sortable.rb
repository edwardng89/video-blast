module UserSortable
  extend ActiveSupport::Concern

  included do
    class_attribute :sort_scopes
    class_attribute :default_sort_option

    ActiveRecord::Relation.include RelationExt
  end

  module RelationExt
    attr_accessor :last_user_sort_key, :last_user_direction

    def last_user_sort
      return unless last_user_sort_key

      [last_user_sort_key, respond_to?(:reverse_order_value) ? (last_user_direction != reverse_order_value) : false]
    end
  end

  module ClassMethods
    def sort_option(name, scope_body = nil, options = nil)
      if scope_body.is_a?(Hash) && options.nil?
        options = scope_body
        scope_body = nil
      end
      options ||= {}

      case scope_body
      when nil
        block = -> { order(name) }
      when String, Symbol
        block = -> { order(scope_body) }
      when Array
        block = -> { order(*scope_body) }
      when Proc
        block = scope_body
      else
        raise ArgumentError, "Don't know how to use #{scope_body.class} as a scope_body"
      end

      self.default_sort_option = name.to_s if options[:default] || default_sort_option.nil?

      # Use merge, instead of #[]=, so we do the right thing if we're in
      # a subclass; we mustn't trample our parent's sort_scopes.
      self.sort_scopes = (sort_scopes || {}).merge(name.to_s => block)
    end

    def valid_sort_option?(name)
      sort_scopes && (name.nil? || sort_scopes.key?(name.to_s))
    end

    def in_order(name = nil)
      if sort_scopes.nil?
        klass = respond_to?(:model_name) ? model_name : self.name
        raise "No sort_option defined for #{klass}"
      end

      name = default_sort_option if name.blank?

      raise "Unknown sort_option: #{name.inspect}" unless s = sort_scopes[name.to_s]

      if result = instance_exec(&s)
        result.extend(RelationExt) unless result.is_a?(RelationExt)
        result.last_user_sort_key = name
        result.last_user_direction = result.reverse_order_value if result.respond_to?(:reverse_order_value)
      end
      result
    end
  end
end
