class Showgap.Views.ShowsIndex extends Backbone.View
  template: JST['shows/index']

  initialize: ->
    @collection.on('reset', @render, this)
    # Can't call appendShow because index displays show count statically
    @collection.on('add', @render, this)
    @collection.on('remove', @render, this)

  events: ->
    'submit #new_show': 'createShow'

  render: ->
    showCount = @collection.length
    @$el.html(@template(
      showsTitle: "#{showCount} #{if showCount == 1 then 'Show' else 'Shows'}"
    ))
    @collection.each(@appendShow)
    this

  # -----------------------
  # Helpers
  # -----------------------

  # Appends a show view item to the show list by passing the template a show
  # model.
  #
  # Returns nothing.
  appendShow: (show) =>
    view = new Showgap.Views.ShowsListShow(model: show)
    @$('.show-list').append(view.render().el)

  # -----------------------
  # Events
  # -----------------------

  # Creates a show on the server based on the values in the #new_show form
  #
  # Returns nothing.
  createShow: (event) ->
    event.preventDefault()
    @removeAlert()

    attributes =
      name: @$('#new_show_name').val()
      description: "Automatic description."

    @collection.create(
      attributes,
      error: @handleError(this)
      success: => @$('#new_show')[0].reset()
    )

  # -----------------------
  # Responses
  # -----------------------

  # Required for handleError
  errorContainer: -> @$('#new_show')
