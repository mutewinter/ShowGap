window.Showgap =
  Models: {}
  Collections: {}
  Views: {}
  Widgets: {}
  Routers: {}
  Mixins: {Model: {}, View: {}}
  Helpers: {}
  User: {} # Holds user methods and currentUser object.
  Show: {} # Holds metadata for current show, preloaded based on subdomain.
  Memoized: # Application-wide memoized functions, shared for performance.
    # Public: Create the date object for an iso string and memoize the result
    # for performance.
    #
    # isoDateString - An ISO formatted date string.
    #
    # Returns the Date object.
    isoToDate: _.memoize (isoDateString) -> Date.create(isoDateString)

  flash: {} # Holds flash messages.
  env: '' # Will contain the Rails environment String.

  # Internal: Loads the view mixins for each view. Mixins under Application
  # will be added to all view.
  #
  # Returns nothing.
  loadMixins: ->
    @loadMixinsInObject(Showgap.Mixins.View, Backbone.View, Showgap.Views)
    @loadMixinsInObject(Showgap.Mixins.Model, Backbone.Model, Showgap.Models)

  # Internal: Generic mixin loader that can load mixins for Bacbkone Views and
  # Models.
  #
  # mixins -      The mixins.
  # global - The global class that will be expended if the mixins are
  #               labeled for Application.
  # objects -     The hash of objects that will be searched for extension of
  #               the mixin is not for the Application.
  #
  # Returns nothing.
  loadMixinsInObject: (mixins, global, objects) ->
    _.each mixins, (mixinObject, name) ->
      if name == "Application"
        _.extend(global.prototype, mixinObject)
      else
        if objects[name]? and 'prototype' of objects[name]
          _.extend(objects[name].prototype, mixinObject)
        else
          console.error "Missing #{name} for Adding Mixins."


  # Internal: Loads the Handlebars helpers found in Showgap.Helpers.
  #
  # Returns nothing.
  loadHelpers: ->
    _.each Showgap.Helpers, (helperObject) ->
      _.each helperObject, (helperFunction, helperName) ->
        # Only load functions that don't start with an underscore.
        if _.isFunction(helperFunction) and !helperName.startsWith('_')
          # Bind allows these helper functions to call other helpers inside
          # their function body.
          Handlebars.registerHelper(helperName, helperFunction, helperObject)

  # Internal: Loads the rules for CanCan and sets up a can helper in the
  # Showgap.User object.
  #
  # Returns nothing.
  loadCanCan: ->
    rules = $('#container').data('rules')
    Showgap.Helpers.CanCan.setRules(rules)
    # Make the can method available to views and models.
    @User.can = Showgap.Helpers.CanCan._can.bind(Showgap.Helpers.CanCan)
    @User.cannot = Showgap.Helpers.CanCan._cannot.bind(Showgap.Helpers.CanCan)

  # Internal: Loads enum definitions for models that have enums and adds them
  # to their respective Backbone model.
  #
  # Returns nothing.
  loadModelEnums: ->
    enums = $('#container').data('enums')
    if enums
      enums.each (enumObject) ->
        _.each enumObject, (enumNames, modelName) ->
          if modelName of Showgap.Models
            Showgap.Models[modelName].prototype.setEnums enumNames
          else
            console.error "Missing Model #{modelName} for enum mixin."


  # Public: Shows a modal error in an iframe. Only works if the environment is
  # development. Intended for showing server errors.
  #
  # response - Response object as returned by a jQuery Ajax request (which
  #            Backbone also uses.)
  #
  # Returns nothing.
  showModalResponseError: (response) ->
    title = "Server Error (#{response.status})"
    if Showgap.env == 'development'
      modalErrorTemplate = JST['application/modal_error']

      $modal = $(modalErrorTemplate(title: title))
      $('body').append($modal)
      $modal.modal(show: true)
      $('iframe', $modal).contents().find('body').append(response.responseText)
    else
      throw new Error("#{title} - #{response.responseText}")

  # Public: Initialize the entire Showgap application. Should only be called
  # after the dom is ready.
  #
  # Returns nothing.
  init: ->
    # Load the mixins and helpers for views and Handlebars respectively.
    @loadMixins()
    @loadHelpers()
    @loadCanCan()
    @loadModelEnums()

    # Create currentUser model based on preloaded data.
    preloadedUser = $('#container').data('current-user')
    @User.currentUser = new Showgap.Models.User(preloadedUser)

    # Create shows collection based on preloaded data.
    preloadedEpisodes = $('#container').data('episodes')
    @episodes = new Showgap.Collections.Episodes(preloadedEpisodes)

    # Setup global variables that are boostrapped by the appliaction.
    @env = $('#container').data('environment')

    if showData = $('#container').data('show')
      # We've got a show (subdomain), so we can load the regular router.
      @Show = new Showgap.Models.Show(showData)
      # Initialize the default (and only) router.
      new Showgap.Routers.Application(episodes: @episodes, show: @Show)
      Backbone.history.start()
    else
      # We don't have a show (subdomain), so we're on the index page. Clear out
      # the loading notification and let Rails render the rest of the page.
      $('#container').text('')

$(document).ready ->
  Showgap.init()
