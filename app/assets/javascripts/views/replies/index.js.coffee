class Showgap.Views.RepliesIndex extends Backbone.View
  template: JST['replies/index']
  formTemplate: JST['replies/form']
  replyPreviewTemplate: JST['replies/reply_preview']

  tagName: 'ul'

  initialize: (options) ->
    # Public: Throttled version of replyInputChanged that only gets called once
    # every 300ms. Note, this is created in the @initialize function so that it
    # exists when events are defined.
    #
    # Returns nothing.
    @throttledReplyInputChanged = _.throttle(@replyInputChanged, 100)

    @collection.on('reset', @render, this)
    @collection.on('add', @render, this)
    @collection.on('change:reply_state', @render, this)
    @collection.on('change:plusminus', @sortAndRender, this)

  # Internal: Called by View mixin when this view is closed.
  #
  # Returns nothing.
  onClose: ->
    if @replyPreviewView
      @replyPreviewView.close()

    @collection.off('reset', @render)
    @collection.off('add', @render)
    @collection.off('change:reply_state', @render)
    @collection.off('change:plusminus', @sortAndRender)

  events: ->
    'submit .new-reply':              'createReply'
    'keyup input, textarea':          'throttledReplyInputChanged'
    'paste input, textarea':          'throttledReplyInputChanged'
    'drop input, textarea':           'throttledReplyInputChanged'
    'click td.detail':  'clickedDetailField'

  # Public: Render the index view and the show view for each reply in the
  # collection.
  #
  # Returns nothing.
  render: ->
    # Close the old reply views before rendering the new ones
    @replyViews.each (replyView) ->
      replyView.close()
    @replyViews = _([])

    replyName = @options.replyName

    templateParameters =
      replyName: replyName
      replyNamePlural: replyName.pluralize()
      hasSuggestedReplies: !!@collection.where(reply_state: 'suggested').length
      hasAcceptedReplies: !!@collection.where(reply_state: 'accepted').length
      isPoll: @options.isPoll

    # Rendering the main templates
    @$el.html(@template(templateParameters))

    # The placeholder for the form changes based on if the user is logged in
    # and if the replies are open for it's parent discussion.
    formPlaceholder = {}
    if @options.areRepliesClosed
      # When replies are closed, the fact that they can't be used takes
      # precedence in the UI over logging in.
      if @options.allowsTitleRepliesOnly
        formPlaceholder =
          title: "#{replyName.titleize()} Suggestions are Closed."
      else
        formPlaceholder =
          title: "#{replyName.titleize()} Suggestions"
          url: "are Closed."
          text: ''

    else if Showgap.User.can('create', 'reply')
      # We're a user with permissions to create replies
      titlePlaceholder = "Title (optional)"

      # Title isn't optional when titles are the only thing allowed
      if @options.allowsTitleRepliesOnly
        titlePlaceholder= "Title"

      urlFormattedReplyName = replyName.pluralize().toLowerCase().remove(' ')

      formPlaceholder =
        title: titlePlaceholder
        url: "http://sexy#{urlFormattedReplyName}.com/sexy1.jpg"
        text: 'Text (keep it short)'
    else
      # We aren't logged in, show this instead of the regular placeholder
      formPlaceholder =
        title: "Log in"
        url: "to Suggest #{replyName.pluralize().titleize()}"
        text: ''

    formClass = ''

    if @options.allowsUrlReplies and @options.allowsTextReplies
      formClass = 'url-and-text'
    else if @options.allowsUrlReplies
      formClass = 'url-only'
    else if @options.allowsTextReplies
      formClass = 'text-only'
    else
      formClass = 'title-only'

    formParameters = _.extend(templateParameters, {
      placeholder: formPlaceholder
      formClass: formClass
      urlReplies: @options.allowsUrlReplies
      textReplies: @options.allowsTextReplies
      urlAndTextReplies: @options.allowsUrlAndTextReplies
      titleOnly: @options.allowsTitleRepliesOnly
      disabled: @options.areRepliesClosed or
        Showgap.User.cannot('create', 'reply')
    })

    @$('.form-wrapper').html(@formTemplate(formParameters))

    # Render the reply templates
    @collection.each(@appendReply)

    this

  # Internal: Holds the reply views so they can be properly closed when the
  # index view is re-rendered.
  replyViews: _([])

  # Public: Sorts the collection before calling render.
  #
  # Returns nothing.
  sortAndRender: (model) ->
    # Sets the highlight property on the model so the view will know to show
    # highlight on the next render.
    model.highlight = true if model
    @collection.sort()

  # Internal: Add a reply to the appropriate reply list.
  #
  # Returns nothing.
  appendReply: (reply) =>
    view = new Showgap.Views.RepliesShow(
      model: reply
      isPoll: @options.isPoll
      hasUserVoted: @options.discussion.hasUserVoted()
      isVotingClosed: @options.isVotingClosed
    )
    @replyViews.push(view)

    if @options.isPoll
      @$('.poll-options').append(view.render().el)
    else
      if reply.is('created') or reply.is('accepted')
        @$('.accepted-replies').append(view.render().el)
      else if reply.is('suggested')
        @$('.suggested-replies').append(view.render().el)
      else
        @$('.suggested-replies').append(view.render().el)

  # Internal: Create a reply with the current parameters in the form.
  #
  # Returns nothing.
  createReply: (event) ->
    event.preventDefault()

    @resetReplyPreview()

    # Ignore the button press if the primary form button is disabled. Keeps
    # from having uncessary server requests for users who aren't logged in.
    return if @$('form .btn-primary').hasClass('disabled')

    @removeAlert()

    reply = new Showgap.Models.Reply(@replyAttributesFromInput())

    reply.save({},
      error: @handleError.bind(this)
      success: @onSuccess
    )

  # Public: Container in which to display the server error.
  errorContainer: -> @$('.new-reply')

  onSuccess: (event) =>
    @$('.new-reply')[0].reset()
    @$titleField().focus().select()

  # Internal: Fetch the attributes for a new reply based on the user's input.
  #
  # options - Options hash used to modify return attributes (default: {}).
  #           preview - If this is is a preview, then we use a fake discussion
  #             parent so the reply isn't accidentally rendered
  #             (default: false).
  #
  # Returns the newly created Reply model.
  replyAttributesFromInput: (attrOptions = {}) ->
    attrOptions = _.extend({preview: false}, attrOptions)

    text = ''
    replyType = 'title'

    urlFieldText = @$urlField().val().trim() if @$urlField().length
    textFieldText = @$textField().val().trim() if @$textField().length

    if @options.allowsUrlAndTextReplies
      # We allow urls and text, we need to determine which one the user intends
      # to use.
      if !@$urlField().is(':disabled') and urlFieldText != ''
        # Url field is enabled and contains text, use it.
        text = @formSanitizedUrl()
        replyType = 'url'
      else if !@$textField().is(':disabled') and textFieldText != ''
        # Text field is enabled and contains text, use it.
        text = textFieldText
        replyType = 'text'

    else if @options.allowsUrlReplies and urlFieldText != ''
      # Urls only, just grab the url input
      text = @formSanitizedUrl()
      replyType = 'url'
    else if @options.allowsTextReplies and textFieldText != ''
      text = textFieldText
      replyType = 'text'

    unless attrOptions.preview
      discussion = @options.discussion

    {
      title: @$titleField().val().trim()
      text: text
      author: Showgap.User.currentUser
      discussion: discussion
      reply_type: replyType
    }

  $titleField: -> @$('.title-field')
  $urlField: -> @$('.url-field')
  $textField: -> @$('.text-field')

  # Internal: Retrieves the url form the url field and sanitizes it.
  #
  # Returns the sanitized url based on the form entry.
  formSanitizedUrl: -> Showgap.Helpers.Url.sanitizeUrl(
    @$urlField().val().trim())

  # Internal: Updates the reply preview shown below the form.
  #
  # Returns nothing.
  updateReplyPreview: ->
    # Defer is required so that the field will properly have the text when
    # the drop event is what called updateReplyPreview.
    _.defer =>
      replyAttributes = @replyAttributesFromInput(preview: true)
      if @replyPreview
        @replyPreview.set(replyAttributes)
      else
        @replyPreview = new Showgap.Models.Reply(replyAttributes)
        @replyPreviewView = new Showgap.Views.RepliesShow(
          model: @replyPreview
          expanded: true
          isVotingClosed: true
        )
        @$('.reply-preview .preview').html(@replyPreviewView.render().el)

      if replyAttributes.title or replyAttributes.text
        # Unhide the reply preview if we have a title or text
        @$('.reply-preview').removeClass('hidden')
      else
        # Hide if if we have no title and text
        @$('.reply-preview').addClass('hidden')

  resetReplyPreview: ->
    if @replyPreviewView
      @replyPreviewView.close()
      @replyPreviewView = null

    @replyPreview = null

  # Internal: Called when the input changes for any of the inputs on the reply
  # form.
  #
  # event - The event that caused the reply to change.
  #
  # Returns nothing.
  replyInputChanged: (event) ->
    if @options.allowsUrlAndTextReplies
      $target = $(event.target)

      if @$textField().val() == '' and @$urlField().val() == ''
        # User has deleted all of the text in both field, therefore we can
        # enable them again.
        @$urlField().prop('disabled', false)
        @$textField().prop('disabled', false)
      else
        # We have text in one of the two fields
        if $target.get(0) == @$urlField().get(0)
          @$textField().prop('disabled', true)
        else if $target.get(0) == @$textField().get(0)
          @$urlField().prop('disabled', true)

    @updateReplyPreview()

  # Internal: Called when the user clicks on of the detail fields (e.g. url or
  # text)
  #
  # event - The click even on the input.
  #
  # Returns nothing.
  clickedDetailField: (event) ->
    $target = $(event.target)
    if $target.prop('disabled')
      if $target.get(0) == @$urlField().get(0)
        # Disabled Url Field Clicked
        @$urlField().prop('disabled', false)
        @$textField().prop('disabled', true)
      else if $target.get(0) == @$textField().get(0)
        # Disabled text field clicked
        @$textField().prop('disabled', false)
        @$urlField().prop('disabled', true)

      @updateReplyPreview()
