module ApplicationHelper
  # Public: Gets all of the enums for a given ActiveRecord model that uses
  # simple_enum.
  #
  # Returns a hash of enum name (without _cd) to the hash of enum symbols to
  #   int values.
  def enums_for_model(model)
    enum_columns = model.column_names.reject{ |c| !(c =~ /_cd$/) }

    enums = {}
    enum_columns.map do |enum|
      enum_name = enum.gsub(/_cd$/, '')
      enum_values = model.send enum_name.pluralize
      enums[enum_name] = enum_values
    end

    enums
  end

  # Public: Gets only the enum value names from a given ActiveRecord model that
  # uses simple_enum.
  #
  # Returns a hash of the model's string name to the array of string enum
  #   names.
  def enum_values_for_model(model)
    enums = enums_for_model(model)
    values = enums.values.map { |e| e.keys.map(&:to_s) }.flatten
    Hash[ model.to_s, values ]
  end

  # Public: Gets the list of singular enum names for a given model.
  #
  # Returns an array of string column names for each enum.
  def enum_names_for_model(model)
    enums = enums_for_model(model)
    Hash[ model.to_s, enums.keys ]
  end

  def enum_names_and_values_for_model(model)
    enums = enums_for_model(model)
    keys_to_values = {}
    enums.each { |name, values| keys_to_values[name] = values.keys }
    Hash[ model.to_s, keys_to_values ]
  end

  # Public: Creates a json partial and defines the format so we don't get a
  # deprecation warning.
  #
  # Returns the rendered json partial.
  def json_partial!(json, template, locals)
    json.partial!(partial: template, formats: :json, locals: locals)
  end
end
