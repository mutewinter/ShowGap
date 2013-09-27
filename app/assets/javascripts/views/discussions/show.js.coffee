# The detail view for a discussion. Shows on the right hand side of the window
# and contains replies, body, and user suggested replies.
class Showgap.Views.DiscussionsShow extends Backbone.View
  template: JST['discussions/show']
  className: 'discussion'

  # Variables
  editMode: false
  saving: false

  events:
    'click .js-edit':  'editClicked'

  initialize: (options) ->
    if 'editMode' of options
      @editMode = options.editMode

  onClose: ->
    @repliesIndex.close() if @repliesIndex

  render: ->
    if @model
      @$el.html(@template(
        discussion: @model.toJSON()
        author: @model.get('author')?.toJSON()
      ))
      @repliesIndex = new Showgap.Views.RepliesIndex(
        discussion: @model
        collection: @model.get('replies')
        replyName: @model.get('reply_name').titleize()
        isPoll: @model.is('poll')
        areRepliesClosed: !!@model.areRepliesClosed()
        allowsUrlReplies: @model.allowsUrlReplies()
        allowsTextReplies: @model.allowsTextReplies()
        allowsUrlAndTextReplies: @model.allowsUrlAndTextReplies()
        allowsTitleRepliesOnly: @model.allowsTitleRepliesOnly()
        isVotingClosed: @model.isVotingClosed()
        el: @$('.replies-container')[0]
      )
      @repliesIndex.render()

      @renderEditMode() if @editMode

    this

  # -----------------------
  # Private Helpers
  # -----------------------

  # Renders the view in show mode, meaning no edit controls are shown.
  #
  # Returns nothing.
  renderShowMode: ->
    @editMode = false
    @render()
    Backbone.history.navigate(@model.clientUrl())

  # Internal: Renders the edit form in place of the data shown.
  #
  # Returns nothing.
  renderEditMode: ->
    Backbone.history.navigate(@model.clientUrl()+'/edit')
    form = new Showgap.Views.FormsShow(
      el: @$el
      className: 'discussion-form'
      model: @model
      saveButtonText: 'Update Discussion'
      showFooterHelp: true
      title: 'Edit Discussion'
    ).render()

    form.on('formClosed', @renderShowMode, this)

  # -----------------------
  # Events
  # -----------------------

  # Called when the user clicks the edit in the discussion view.
  #
  # Returns nothing.
  editClicked: (event) =>
    event.preventDefault()
    @renderEditMode()
