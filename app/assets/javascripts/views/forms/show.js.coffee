# Public: A wrapper for Backbone.Form that handles saving and server errors.
class Showgap.Views.FormsShow extends Backbone.View
  # Templates
  errorTemplate: JST['forms/error']

  # Internal: Called with extra options passed to constructor.
  #
  # options -
  #           modelClass - Class for the model to use for the form.
  #           model - Specific, instantiated model, to use for the form.
  #           saveButtonText - String to use for the form save button.
  #           $viewToHide - jQuery object for the view that should be hidden
  #             while the form is visible.
  #           collection - Collection to add the model to once the server has
  #             indicated it was saved successfully.
  #           attrToFocus - Attribute to focus when the form is first rendered
  #             (defaults to first field).
  #           showFooterHelp - Whether to show the footer for the form
  #             containing a hint about which fields are required.
  #           title - The title to be placed above the form.
  #           extraAttributes - Object that should be added to the model when
  #             saved. These will not be validated. An example use would be
  #             to provide a related record in a HasMany relationship.
  #
  # Returns nothing.
  initialize: (options) ->
    # Extra options that should be assigned to this object. So we can call
    # @property instead of @options.property
    optionNames = _(['modelClass', 'saveButtonText', '$viewToHide',
      'attrToFocus', 'showFooterHelp', 'title', 'extraAttributes'])
    optionNames.each (optionName) =>
      @[optionName] = options[optionName]

    @extraAttributes ?= {}

    @on('validationError', @onValidationError)
    @on('beforeSave', @onBeforeSave)

  # Internal: Close the form and show the @$viewToHide.
  #
  # Returns nothing.
  onClose: ->
    @form.close()
    @$viewToHide.show() if @$viewToHide

  events:
    'click .js-save':    'saveClicked'
    'click .js-cancel':  'cancelClicked'
    'submit form':       'formSubmitted'
    'keypress form':     'formKeyPressed'

  # -----------------------
  # Rendering
  # -----------------------

  # Public: Renders the Backbone Form into the supplied el.
  #
  # Returns the FormsShow view.
  render: ->
    # Create a new div inside the supplied element so we don't accidentally
    # remove that element when we are closed. This is done so the caller can
    # continually reuse the wrapper they created for the form without having
    # to add the extra element themselves every time.
    $newEl = $('<div/>')
    @$el.empty().append($newEl)
    @$el = $newEl

    # Create the model if we weren't given one.
    @model = new @modelClass unless @model?

    @$viewToHide.hide() if @$viewToHide

    @form = new Backbone.Form(
      model: @model
    )
    @$el.html @form.render().el

    @renderFormCustomizations()

    @onFirstRender() unless @hasRendered
    # Keep track of whether this is our first render or not.
    @hasRendered = true

    this

  # Internal: Render all of the customizatoins we want to do to our form.
  #
  # Returns nothing.
  renderFormCustomizations: ->
    # Regular Additions
    @renderPlaceholders()
    @addValidationClasses()

    # Conditional Additions
    @form.$el.addClass @className if @className
    @form.$('.js-save').text(@saveButtonText) if @saveButtonText
    @form.$('footer').show() if @showFooterHelp
    @form.$('.form-title').show().text(@title) if @title


  # Internal: Adds classes to the control-group for each input named after
  # their validtion type.
  #
  # Returns nothing.
  addValidationClasses: ->
    # Names of validations that we will add as classes to the control-group for
    # a field.
    validClasses = ['required']

    _.each @model.schema, (properties, field) =>
      if _.isObject(properties) and 'validators' of properties
        validators = properties.validators
        _.each validators, (validator) =>
          if _.isString(validator) and _.include(validClasses, validator)
            @addClassToControlGroup(validator, field)
          else if _.isObject(validator) and 'type' of validator and
          _.include(validClasses, validator.type)
            @addClassToControlGroup(validator.type, field)


  # Internal: Renders the HTML5 placeholders found in the schema for the model.
  #
  # Returns nothing.
  renderPlaceholders: ->
    _.each @model.schema, (properties, field) =>
      if _.isObject(properties) and 'placeholder' of properties
        @fieldForName(field).attr('placeholder',
          "e.g. #{properties.placeholder}")

  # Internal: Called only once, after the first render.
  #
  # Returns nothing.
  onFirstRender: ->
    if @attrToFocus
      @$("form *:[name=#{@attrToFocus}]:first").focus()
    else
      @$allInputs().not(':hidden').first().focus()

  # -----------------------
  # Saving
  # -----------------------

  # Internal: Attempts to commit the form and save the model on the server.
  #
  # Returns nothing.
  saveModel: ->
    # Clear old errors.
    @clearOtherErrors()

    errors = @form.validate()

    if errors
      @trigger('validationError')
      @showOtherErrors errors._others if '_others' of errors
    else
      @form.commit()

      # Optomisitcally add the model to the collection, we'll remove it on a
      # server error.
      @collection.add @model if @collection

      @trigger('beforeSave')

      @model.save(@extraAttributes,
        error: @onSaveError
        success: @onSaveSuccess
      )

  # Internal: Called when there is an error saving the model (most likely on
  # the server).
  #
  # Returns nothing.
  onSaveError: (model, response) =>
    @trigger('validationError')

    # Remove the model that we optimistically added to the collection.
    @collection.remove model if @collection

    switch response.status
      when 403
        # TODO
        # Handle this error differently since it's forbidden, e.g. they need
        # to login.
        @showErrorsForRepsonse(response)
      when 422
        @showErrorsForRepsonse(response)
      else
        # We don't know what to do with response statuses other than 422
        Showgap.showModalResponseError(response)

  # Internal: Called when the model saves successfully on the server. Triggers
  # afterSave event for anyone watching this view with the model.
  #
  # Returns nothing.
  onSaveSuccess: (model, response) =>
    @trigger('formClosed')
    @close()

  # -----------------------
  # Helpers
  # -----------------------

  # Internal: Returns the jQuery object for a field of a given name.
  fieldForName: (name) -> @form.fields[name].editor.$el

  # Internal: Returns the control-group div for a given field name.
  controlGroupForName: (name) -> @form.fields[name].$el

  # Internal: Adds a class to the control group for a given field name.
  #
  # Returns nothing.
  addClassToControlGroup: (className, field) ->
    @controlGroupForName(field).addClass(className)

  # Internal: Returns the jQuery objects for all of the inputs in this form.
  $allInputs: -> @form.$('input, textarea, select')

  # -----------------------
  # Error Display
  # -----------------------

  # Internal: Displays errors from the server, inline where possible and then
  # in the other error container if not.
  #
  # response - jQuery Ajax response object.
  #
  # Returns nothing.
  showErrorsForRepsonse: (response) ->
    # Validation errors, easy peasy
    serverErrors = @parseRailsErrors(response.responseText)

    if _.isObject serverErrors
      # We got a regular Rails validation error, show them inline where
      # possible.
      serverErrorFields = _.keys serverErrors
      fieldNames = _.keys @form.fields

      # Fields the server has errors with that are also in this form.
      validFields = _.intersection fieldNames, serverErrorFields
      # Fields the server has errors with that aren't in this form.
      otherFields = _.difference serverErrorFields, validFields

      validErrors = _.pick serverErrors, validFields
      otherErrors = _.pick serverErrors, otherFields

      # Display the inline errors for all of the valid fields
      _.each validErrors, (errors, field) =>
        @form.fields[field].setError errors.join(', ')

      # Show the other errors for fields we don't know about
      @showOtherErrors otherErrors unless _.isEmpty otherFields
    else
      # We just got back a String error from the server, show it as an
      # other error.
      @showOtherErrors serverErrors

  # Internal: Shows errors that don't belong with a specific field.
  #
  # otherErrors - A String error message, an array of String error messages,
  #               or an Array of Objects containing field: error_message.
  #
  # Returns nothing.
  showOtherErrors: (otherErrors) ->
    errorsToDisplay = []

    if _.isArray otherErrors
      # An array of errors, which could be strings or objects.
      _.each otherErrors, (error) ->
        if _.isString error
          # Just a string, add it to errors array.
          errorsToDisplay.push error
        else if _.isObject error
          # We've run into an object, create error strings out of the key value
          # pairs and display them as errors.
          _.each error, (message, field) ->
            errorsToDisplay.push "#{field.humanize().titleize()} #{message}"
        else
          console.error otherErrors
          throw new Error('Unrecognized error format.')

    else if _.isString otherErrors
      # A string by itself.
      errorsToDisplay = [otherErrors]
    else if _.isObject otherErrors
      # An object of field: ['error1', 'error2']
      _.each otherErrors, (errors, field) ->
        _.each errors, (message) ->
          errorsToDisplay.push "#{field.humanize().titleize()} #{message}"
    else
      console.error otherErrors
      throw new Error('Unrecognized error format.')

    @$('.other-errors').empty().html @errorTemplate(errors: errorsToDisplay)

  # Internal: Parses the JSON Rails error response into a JavaScript object.
  #
  # responseText - The JSON String response from the server.
  #
  # Returns the error JavaScript object.
  parseRailsErrors: (responseText) ->
    parsedJSON = $.parseJSON(responseText)
    if 'errors' of parsedJSON
      parsedJSON.errors
    else if 'error' of parsedJSON
      parsedJSON.error
    else
      console.error "Parsed Response ", parsedJSON
      throw new Error('Errors not found in parsed response.')

  # Internal: Clears the other errors div.
  #
  # Returns nothing.
  clearOtherErrors: ->
    @$('.other-errors').empty()

  # -----------------------
  # Event Listeners
  # -----------------------

  # Internal: Called before the model is saved, allowing the form to be
  # disbaled and the save button to be changed to Loading text.
  #
  # Returns nothing.
  onBeforeSave: ->
    # Mark the button as saving and hide the cancel button.
    @form.$('.js-save').button('loading')
    @form.$('.js-cancel').css(visibility: 'hidden')
    @$allInputs().prop('disabled', true)


  # Internal: Called when there is any form error. Resets anything with the
  # form that is set when the submits it and it then fails. Also moves focus to
  # the first error.
  #
  # Returns nothing.
  onValidationError: ->
    # Re-enable the save button.
    @form.$('.js-save').button('reset')
    @form.$('.js-cancel').css(visibility: 'visible')
    @$allInputs().prop('disabled', false)

    # Focus the first field with an error.
    _.defer =>
      if $errorGroup = @$('.control-group.error:first')
        # Find the first valid input control within the error container and
        # focus it.
        $('input:first, textarea:first, select:first', $errorGroup).focus()

  # -----------------------
  # User Initiated Events
  # -----------------------

  # Internal: Called when the user clicks the save button below the form.
  #
  # Returns nothing.
  saveClicked: (event) =>
    event.preventDefault()
    @saveModel()

  # Internal: Creates a new episode and removes the form if the form is valid,
  # otherwise shows the inline errors.
  #
  # Returns nothing.
  formSubmitted: (event) =>
    event.preventDefault()
    @saveModel()

  # Public: Called when a user presses a key within the form.
  #
  # Returns nothing.
  formKeyPressed: (event) ->
    # Enter key pressed, submit the form
    if event.which == 13
      event.preventDefault()
      @formSubmitted(event)

  # Internal: Called when the user clicks the cancel button below the form.
  #
  # Returns nothing.
  cancelClicked: (event) =>
    event.preventDefault()
    @trigger('formClosed')
    @close()
