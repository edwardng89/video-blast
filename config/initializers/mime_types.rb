# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'application/vnd.ms-excel', :xls
Mime::Type.register 'application/pdf', :pdf

##
# Renders an excel file representation of a collection.
# @param obj (Object) is the collection to be represented in the excel file (it will attempt to be decorated)
# @param options (Hash) {
#   decorator_class: (decorator to be used, if not defined .decorate is called),
#   scope: (scope to apply to the records, by default this is :for_csv and should just include),
#   filename: (the name of the file produced, defaults to 'data'),
# }
# @return (Binary)
ActionController::Renderers.add :xls do |obj, options|
  filename = options[:filename] || ApplicationDecorator.xls_filename(controller_name) || 'data'
  scope = options[:scope] || :for_xls
  decorator_class = options[:decorator_class]

  records = obj.respond_to?(scope, true) ? obj.public_send(scope) : obj
  rows = records.map do |r|
    if r.respond_to?(:decorate) && !decorator_class
      r.decorate
    elsif decorator_class
      decorator_class.new(r)
    else
      r
    end
  end

  rows = rows.map(&:as_xls)
  excel = Axlsx::Package.new

  excel.workbook.add_worksheet(name: options[:sheet_name]) do |sheet|
    excel.use_autowidth = true

    excel.workbook.styles do |s|
      header_style = s.add_style(sz: 12, b: true)

      rows.each_with_index do |row, index|
        # Add a Header if we are the first row
        if index == 0
          header_row = row.is_a?(Array) ? rows[0][0] : rows[0]
          sheet.add_row header_row.keys.map { |k| k.to_s.humanize }, style: header_style
        end
        # Lets make the plain row an array, then we can handle either
        row = [row] unless row.is_a?(Array)
        row.each do |row|
          sheet.add_row(row.values.map { |x| x.is_a?(Date) || x.is_a?(Time) ? x.to_s(:csv) : x })
        end
      end
    end
  end

  send_data excel.to_stream.read, filename: "#{filename.parameterize}.xlsx"
end

##
# Renders a CSV file representation of a collection.
# @param obj (Object) is the collection to be represented in the CSV file (it will attempt to be decorated)
# @param options (Hash) {
#   decorator_class: (decorator to be used, if not defined .decorate is called),
#   scope: (scope to apply to the records, by default this is :for_csv),
#   filename: (the name of the file produced, defaults to 'data'),
# }
# @return (Binary)
ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  scope = options[:scope] || :for_csv
  decorator_class = options[:decorator_class]
  parameters = options[:parameters]

  # Use a 'for_csv' scope if it's available. For everyone's sanity,
  # the only thing that scope should be doing is calling includes().
  records = (obj.respond_to?(scope) ? obj.public_send(scope) : obj)
  keys = nil
  csv = CSV.new('')

  if decorator_class
    records = decorator_class.decorate_collection(records)
  elsif records.respond_to?(:decorate)
    records = records.decorate
  end

  records.each do |o|
    h = if o.respond_to?(:as_csv)
          if parameters.present?
            o.as_csv(*parameters)
          else
            o.as_csv
          end
        elsif parameters.present?
          o.as_json(*parameters)
        else
          o.as_json
        end

    # Handling array so the as_csv method can decide if a record should be multiple rows
    if h.is_a?(Array)
      rows = h
      h = rows.first
    else
      rows = [h]
    end

    unless keys
      keys = h.keys
      csv << keys
    end

    rows.each do |row|
      row = row.values_at(*keys)
      row.map! { |x| x.is_a?(Date) || x.is_a?(Time) ? x.to_s(:csv) : x }

      csv << row
    end
  end

  str = csv.string
  ext = options[:extension] || 'csv'

  send_data str, type: Mime[:csv], disposition: "attachment; filename=#{filename.parameterize}.#{ext}"
end
