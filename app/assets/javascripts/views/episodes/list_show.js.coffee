class Showgap.Views.EpisodesListShow extends Backbone.View
  template: JST['episodes/list_show']
  tagName: 'li'
  className: 'episode row'

  events: ->
    # Confirm before destroying
    'click .btn.js-destroy': 'destroyConfirm'
    # Destroy confirmed, remove from model and server
    'click .btn.js-destroy.confirm': 'destroyEpisode'
    # Destroy cancelled, set buttons back to normal
    'click .btn.js-cancel': 'cancelDestroy'

  initialize: ->
    @model.on('change', @render, this)

  render: ->
    questions = @model.questions()
    polls = @model.polls()

    if questions.length
      questionWord = if questions.length == 1 then 'Question' else 'Questions'
    if polls.length
      pollWord = if polls.length == 1 then 'Poll' else 'Polls'

    @$el.html(@template(
      url: @model.clientUrl()
      episodeTitle: @model.episodeTitle()
      questionText: "#{@model.questions().length} #{questionWord}" if questionWord
      pollText: "#{@model.polls().length} #{pollWord}" if pollWord
      titlesText: "Placeholder Title Count"
      recordDate: @model.recordDateLong()
      isoRecordDate: @model.get('record_date')
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

  # Closes this view and destroys the episode.
  #
  # Returns nothing.
  destroyEpisode: (event) ->
    @model.destroy(
      error: @handleError.bind(this)
      success: @close.bind(this)
    )
