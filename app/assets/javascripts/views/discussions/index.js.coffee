class Showgap.Views.DiscussionsIndex extends Backbone.View
  template: JST['discussions/index']

  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendDiscussion, this)

  events: ->
    'submit .new-discussion':    'createDiscussion'
    'keypress .new-discussion':  'formKeyPressed'
    'click .templates':          'templateButtonClicked'

  render: ->
    @$el.html(@template(
      numberOfDiscussions: @collection.length
    ))

    # Not checking size here causes  this error in Underscore:
    # Uncaught TypeError: undefined is not a function
    if @collection.length
      @collection.each(@appendDiscussion)

    this

  # -----------------------
  # Helpers
  # -----------------------

  # Internal: Appends the discussion to the discussion-list list.
  #
  # Returns the view for the newly rendered discussion.
  appendDiscussion: (discussion) =>
    view = new Showgap.Views.DiscussionsListShow(model: discussion)
    @$('.discussion-list').append(view.render().el)
    view

  # -----------------------
  # Events
  # -----------------------

  createDiscussion: (event) ->
    event.preventDefault()

    @removeAlert()

    templateName = @$('.new-discussion .templates .btn.active').text()
    discussion = Showgap.Models.Discussion.Factory(templateName)

    discussion.set(
      title: @$('.new-discussion .title-field').val()
      episode: @options.episode
      author: Showgap.User.currentUser
    )

    discussion.save({},
      error: @handleError.bind(this)
      success: @onSuccess
    )

  # Public: Called when a user presses a key within this view.
  #
  # Returns nothing.
  formKeyPressed: (event) ->
    # Enter key pressed, submit the form
    if event.which == 13
      event.preventDefault()
      @createDiscussion(event)

  # Internal: Clicks the last discussion in the list (the new one), focuses the
  # discussion title input and clears it.
  #
  # Returns nothing.
  onSuccess: (discussion) ->
    # Show the discussion as soon as it's added
    Backbone.history.navigate(discussion.clientUrl(), trigger: true)

  # Define the errorContainer for the @handleError function
  # that is defined in the Backbone.View prototype
  #
  # Returns nothing.
  errorContainer: -> @$('.new-discussion')

  templateButtonClicked: (event) ->
    event.preventDefault()

    templateName = $(event.target).text()
    suggestedName = ''

    switch templateName
      when 'Show Titles'
        suggestedName = 'Suggest a Show Title'
      when 'Question'
        suggestedName = 'Audience Question'
      when 'None'
        suggestedName = ''
      else
        suggestedName = templateName

    @$('.new-discussion .title-field').val suggestedName
