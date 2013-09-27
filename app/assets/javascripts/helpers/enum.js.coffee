# Public: Enum helpers to look at model enums in a Handlebars view.
Showgap.Helpers.Enum =
  # Public: Checks if the model's enum is set to a given value.
  #
  # model     - Backbone model with one or many enums defined.
  # enumValue - String value of the enum that should be checked.
  #
  # Returns the block if the is method returns true for the model.
  is: (model, enumValue, options) ->
    if model.is(enumValue)
      options.fn(this)
    else
      options.inverse(this)

