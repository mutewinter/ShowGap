class Showgap.Views.RepliesShow extends Backbone.View
  template: JST['replies/show']
  tagName: 'li'
  className: 'discussion-reply'

  initialize: ->
    # All other attributes should cause the parent view to rerender
    @model.on('change:title change:text', @render, this)

  onClose: ->
    @model.off('change:title change:text', @render)
    @expander.close() if @expander

  events: ->
    'click .js-accept':     'acceptReply'
    'click .js-decline':    'unacceptReply'
    'click .js-destroy':    'destroyReply'
    'click .js-vote-up':    'voteUp'
    'click .js-vote-down':  'voteDown'

  render: ->
    @$el.html(@template(
      reply: @model.toJSON()
      replyModel: @model
      relativeDate: Date.create(@model.get('created_at')).relative()
      button: @stateButton()
      author: @model.get('author')?.toJSON()
      downVotes: @model.areDownVotesAllowed()
      exclusiveVotes: @options.isPoll and @options.hasUserVoted
      isVotingClosed: @options.isVotingClosed
      isPoll: @options.isPoll
      domain: @model.domain()
    ))

    if @model.highlight
      @model.highlight = false
      @$el.addClass 'highlight'

    if @model.is 'text'
      text = @model.get('text')
      # Remove the expander view if we already defined one
      @expander = new Showgap.Widgets.Expander(
        el: @$('.reply-text')
        text: text
        maximumLines: 2
        expanded: @options.expanded
      ).render()

    this

  # Internal: Create the properties for the host button based on the state of
  # the reply.
  #
  # Returns a hash containing the class and text keys.
  stateButton: ->
     if @model.is('suggested')
       class: 'btn-success js-accept'
       text: 'Accept'
     else if @model.is('accepted')
       class: 'js-decline'
       text: 'Decline'
     else
       null

  # Internal: Mark the reply model for this view as accepted and save it.
  #
  # Returns nothing.
  acceptReply: (event) ->
    event.preventDefault()
    @model.setAccepted()
    @model.save()

  # Internal: Mark the reply model for this view as suggested save it.
  #
  # Returns nothing.
  unacceptReply: (event) ->
    event.preventDefault()
    @model.setSuggested()
    @model.save()

  destroyReply: (event) ->
    event.preventDefault()
    @model.destroy()
    @close()

  voteUp: (event) ->
    event.preventDefault()
    @castVote 'up'

  voteDown: (event) ->
    event.preventDefault()
    @castVote 'down' if @model.areDownVotesAllowed()

  # Internal: Casts a vote for the given user on this view's model with the
  # given direction.
  #
  # direction - String direction, either 'up' or 'down'
  #
  # Returns nothing.
  castVote: (direction) ->
    return if @options.isVotingClosed

    # Already voted flag set to true if this model thinks the user has voted
    # (the vote has shown in the UI).  If they don't think they've voted, then
    # we shouldn't allow them to change their vote.
    alreadyVoted = !!(@model.get('voted_for') || @model.get('voted_against'))

    $.ajax(
      type: 'POST',
      url: "#{@model.url()}/vote",
      data: {direction: direction, already_voted: alreadyVoted}
      success: (attributes) =>
        @model.set(attributes)
      dataType: 'json'
    )
    .error(@handleError.bind(this, @model))

  # Temporary error container for votes to display errors.
  errorContainer: -> @$el.parent()
