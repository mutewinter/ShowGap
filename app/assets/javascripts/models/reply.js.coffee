class Showgap.Models.Reply extends Backbone.RelationalModel
  # Url without api or specific episode
  baseUrl: ->
    discussion = @get('discussion')
    discussion_id = discussion.id
    episode_id = discussion.get('episode').id
    "episodes/#{episode_id}/discussions/#{discussion_id}/replies"

  urlRoot: -> "/api/#{@baseUrl()}"
  clientUrl: -> "#{@baseUrl()}/#{@id}"


  relations: [
    {
      type: Backbone.HasOne
      key: 'author'
      relatedModel: 'Showgap.Models.User'
      includeInJSON: false
      reverseRelation:
        type: Backbone.HasMany
        key: 'replies'
        # Not included in json since it's not needed on the server.
        includeInJSON: false
    }
  ]

  validate: (attrs) ->
    if !attrs.title and !attrs.text
      return "Both the Title and the Text of your Reply can't be blank."

    discussion = @get('discussion')
    if discussion and discussion.hasUniqueReplies() and
    (attrs.title or attrs.text)

      # Will be set if an error is found to break the loop below
      errorMessage = false

      discussion.get('replies').each (reply) =>
        return if errorMessage

        # Checking for reply.id's existance ensures we don't check against the
        # already-created version of this reply in the parent discussion
        # colection when saving.
        if reply.id and reply.id != attrs.id
          # This reply isn't the same one we're inside of
          if attrs.title and reply.get('title') == attrs.title
            errorMessage =
              'A reply with a title like yours has already been submitted.'
          if attrs.text and reply.get('text') == attrs.text
            type = 'content'
            if reply.is('text')
              type = 'text'
            else if reply.is('url')
              type = 'a url'

            errorMessage =
              "A reply with #{type} like yours has already been submitted."

      return errorMessage if errorMessage


    # Return nothing to signify validation has passed
    return

  # -----------------
  # Helpers
  # -----------------

  # Public: Find out if down votes are allow for this discussion.
  #
  # Returns true if down votes are allowed.
  areDownVotesAllowed: ->
    if @get('discussion')
      @get('discussion').areDownVotesAllowed()

  # Public: Converts the text property into a URI and then returns the
  # domain if this model is listed as a URL.
  #
  # Returns the domain string for the URI in the text property.
  domain: ->
    if @is('url')
      uri = URI(@get('text'))
      if uri.subdomain() == 'www'
        uri.domain()
      else
        uri.hostname()
    else
      ''
