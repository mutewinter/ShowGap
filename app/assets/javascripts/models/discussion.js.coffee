class Showgap.Models.Discussion extends Backbone.RelationalModel
  urlRoot: -> "/api/episodes/#{@get('episode').id}/discussions"
  clientUrl: -> "episodes/#{@get('episode').id}/discussions/#{@id}"

  initialize: ->
    # For backbone-forms, defines the fields and their editors.
    @schema =
      title:
        type: 'Text'
        validators: [
          type: 'required', message: "It isn't much of a discussion without a title."
        ]
        placeholder: "What's a Good Show Title?"
      body:
        type: 'Wysihtml5'
        fieldClass: 'wysihtml5-field'
        editorClass: 'discussion-body'
      reply_name:
        type: 'Text'
        title: 'Reply Name'
        validators: [type: 'required', message: 'We need to know what to call these the replies you get.']
        placeholder: 'Show Title'
      voting_open:
        type: 'Checkbox'
        title: 'Voting Open'
      replies_open:
        type: 'Checkbox'
        title: 'Replies Open'
      unique_replies:
        type: 'Checkbox'
        title: 'Require Unique Replies'
      allows_url_replies:
        type: 'Checkbox'
        title: 'Allow Url Replies'
      allows_text_replies:
        type: 'Checkbox'
        title: 'Allow Text Replies'

  # Internal: Creates the array of objects used for Backbone-Forms to create a
  # radio button for a given enum field.
  #
  # Returns the array of object which contain a val and label key value set.
  selectMap: (field) ->
    _.map @enumKeys(field), (key, value) ->
      val: key, label: key.humanize().titleize()

  # -----------------
  # Class Methods
  # -----------------

  # Public: Creates a predefined discussion based on a given name.
  #
  # name - String name of the factory to use for this discussion.
  #
  # Returns the created, but not saved to server, Discussion model.
  @Factory: (name) ->
    switch name
      when 'Show Titles'
        new Showgap.Models.Discussion(
          allows_url_replies: false
          allows_text_replies: false
          unique_replies: true
          discussion_type: 'question'
          reply_name: 'Show Title'
        )
      when 'Poll'
        new Showgap.Models.Discussion(
          allows_text_replies: false
          discussion_type: 'poll'
          reply_name: 'Poll Item'
        )
      when 'Question'
        new Showgap.Models.Discussion(
          discussion_type: 'question'
          unique_replies: true
          reply_name: 'Answer'
        )
      else
        new Showgap.Models.Discussion

  # -----------------
  # Relations
  # -----------------

  relations: [
    {
      type: Backbone.HasMany
      key: 'replies'
      relatedModel: 'Showgap.Models.Reply'
      collectionType: 'Showgap.Collections.Replies'
      reverseRelation:
        key: 'discussion'
        includeInJSON: 'id'
        keyDestination: 'discussion_id'
    },
    {
      type: Backbone.HasOne
      key: 'author'
      relatedModel: 'Showgap.Models.User'
      reverseRelation:
        type: Backbone.HasMany
        key: 'discussions'
        # Not included in json since it's not needed on the server.
        includeInJSON: false
    }
  ]

  # -----------------
  # Helpers
  # -----------------

  isVotingOpen: -> @get('voting_open')
  isVotingClosed: -> not @get('voting_open')
  areRepliesOpen: -> @get('replies_open')
  areRepliesClosed: -> not @get('replies_open')
  # Public: Find out if down votes are allow for this discussion.
  #
  # Returns true if down votes are allowed.
  areDownVotesAllowed: -> !@is('poll')

  hasUserVoted: ->
    hasVoted = false
    @get('replies').each (reply) ->
      if reply.get('voted_for')
        hasVoted = true

    return hasVoted

  allowsUrlReplies: -> @get('allows_url_replies')
  allowsTextReplies: -> @get('allows_text_replies')
  allowsUrlAndTextReplies: -> @allowsTextReplies() and @allowsUrlReplies()
  allowsTitleRepliesOnly: -> !@allowsTextReplies() and !@allowsUrlReplies()
  hasUniqueReplies: -> @get('unique_replies')
