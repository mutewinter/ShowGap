class Showgap.Views.ShowsListShow extends Backbone.View
  template: JST['shows/list_show']
  tagName: 'li'

  events: ->
    # Confirm before destroying
    'click .btn.js-destroy': 'destroyConfirm'
    # Destroy confirmed, remove from model and server
    'click .btn.js-destroy.confirm': 'destroyShow'
    # Destroy cancelled, set buttons back to normal
    'click .btn.js-cancel': 'cancelDestroy'

  initialize: ->
    @model.on('change', @render, this)

  render: ->
    discussions = @model.get('discussions')
    @$el.html(@template(
      url: @model.clientUrl()
      name: @model.get('name')
      discussionsText: discussions.map((discussion) ->
        discussion.get('name')).join(', ')
      discussionsTitle: discussions.discussionsAmountText()
    ))
    @$('.has-popover').popover(placement: 'left')
    this

  onClose: ->
    @model.unbind('change', @render)

  # -----------------------
  # Events
  # -----------------------

  # ------------
  # Destroy
  # ------------

  confirmingDestroy: false

  # Show the confirmation button before calling the delete action.
  #
  # Returns nothing.
  destroyConfirm: (event) ->
    event.preventDefault()
    unless @confirmingDestroy
      @confirmingDestroy = true
      @$('.btn.js-destroy').text("Yes, I'm sure.")
      @$('.btn.js-destroy').addClass('btn-danger confirm')
      $cancel = $('<a class="btn btn-mini js-cancel">Cancel</a>')
      @$('.btn.js-destroy').after($cancel)

  # Remove the cancel button and set the delete button text back to Delete.
  #
  # Returns nothing.
  cancelDestroy: (event) ->
    event.preventDefault()
    @confirmingDestroy = false
    @$('.btn.js-destroy').text('Delete')
    @$('.btn.js-destroy').removeClass('btn-danger confirm')
    @$('.btn.js-cancel').remove()

  # Closes this view and destroys the show.
  #
  # Returns nothing.
  destroyShow: (event) ->
    @model.destroy(
      error: @handleError.bind(this)
      success: @close.bind(this)
    )
