# Public: Application-wide helpers meant for handlebars.
Showgap.Helpers.Application =

  # -----------------------
  # String Helper Methods
  # -----------------------

  lowercase: (string) -> string.toLowerCase() if string
  titleize: (string) -> string.titleize() if string

  articleForString: (string) ->
    if string
      if string.match(/^(a|e|i|o|u)/i) then 'an' else 'a'

  # Public: Calls the function and returns the block if the function returns
  # true.
  #
  # object       - Object that contains the functionName.
  # functionName - The String name of the function to be called.
  # options      - Handlebars style object options.
  #
  # Returns the block if the function passed evaluates to true, the inverse if
  # not.
  bool: (object, functionName, options) ->
    if !!object[functionName].call(object)
      options.fn(this)
    else
      options.inverse(this)
