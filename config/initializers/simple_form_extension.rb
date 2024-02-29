# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :checkbox, tag: 'div', class: 'input', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :input, class: 'boolean optional css-checkbox'
    b.use :label, class: 'css-label'

    b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'check-box-hint' }
  end
end
