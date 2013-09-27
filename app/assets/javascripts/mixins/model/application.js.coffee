# Public: Mixins for the entire application's models.
Showgap.Mixins.Model.Application =
  # Will be populated on inital load in showgap.coffee
  # Internal: Enum names mapped to enum values in JS Object.
  _enums: {}
  # Internal: Enum names only for checing with @is method.
  _enumNames: []

  # Public: Checks if an enum value is set.
  #
  # value - String value of any enum in this model.
  #
  # Returns true if the value of any enum in this model is the given string.
  is: (value) ->
    # Collect the values of all enums into string array
    enumValues = @_enumNames.map (field) => @get(field)
    # Check if any of the values matches the value strin)
    _.include(enumValues, value)

  # Public: Checks if an enum value isn't set.
  isnt: (value) -> !@is(value)

  # Public: Set the enum names to something new
  #
  # Returns nothing.
  setEnums: (enums) ->
    @_enums = _.clone(enums)
    # Extract only the enum names
    @_enumNames = _.keys enums

    @_createEnumSetMethods()

  # Public: Creates an array of the valid keys for the given field name.
  #
  # Returns the array of keys.
  enumKeys: (field) -> @_enums[field]

  # Internal: Creates the setEnumValue methods for the model so it can behave
  # like simple_enum in rails.
  _createEnumSetMethods: ->
    _.each @_enums, (values, enumName) =>
      values.each (enumValue) =>
        camelized = enumValue.camelize().capitalize()
        methodName = "set#{camelized}"
        @[methodName] = ->
          @set(enumName, enumValue)
