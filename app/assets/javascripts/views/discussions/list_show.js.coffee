class Showgap.Views.DiscussionsListShow extends Backbone.View
  template: JST['discussions/list_show']
  tagName: 'li'

  events: ->
    'click a.discussion':             'discussionClicked'
    'click .btn.js-destroy':          'destroyConfirm'
    'click .btn.js-destroy.confirm':  'destroyDiscussion'
    'click .btn.js-cancel':           'cancelDestroy'

  initialize: (options) ->
    @model.on('change', @render, this)

  render: ->
    @$el.html(@template(
      url: @model.clientUrl()
      title: @model.get('title')
      replyCount: @model.get('replies').size()
    ))
    this

  onClose: ->
    @model.unbind('change', @render)

  # -----------------------
  # Events
  # -----------------------

  # Opens the detail view for this discussion when clicked.
  #
  # Returns nothing.
  discussionClicked: (event) =>
    event.preventDefault()
    Backbone.history.navigate(@model.clientUrl(), trigger: true)

  # ------------
  # Destroy
  # ------------

  confirmingDestroy: false

  destroyConfirm: (event) ->
    event.preventDefault()
    # Required to keep discussionClicked from firing.
    event.stopPropagation()
    unless @confirmingDestroy
      @confirmingDestroy = true
      @$('.btn.js-destroy').text("Yes, I'm sure.")
      @$('.btn.js-destroy').addClass('btn-danger confirm')
      cancel = $('<a class="btn btn-mini js-cancel">Cancel</a>')
      @$('.btn.js-destroy').after(cancel)

  cancelDestroy: (event) ->
    event.preventDefault()
    # Required to keep discussionClicked from firing.
    event.stopPropagation()
    @confirmingDestroy = false
    @$('.btn.js-destroy').text('Delete')
    @$('.btn.js-destroy').removeClass('btn-danger confirm')
    @$('.btn.js-cancel').remove()

  destroyDiscussion: (event) ->
    @model.destroy(
      error: @handleError.bind(this)
      success: @close.bind(this)
    )

