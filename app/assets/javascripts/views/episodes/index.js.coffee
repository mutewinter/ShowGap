class Showgap.Views.EpisodesIndex extends Backbone.View
  template: JST['episodes/index']

  childViews: _([])

  initialize: (options) ->
    # Show in which these epidoes are being created, used to assign the show in
    # the client when creating new episodes.
    @show = options.show

    @collection.on('reset', @render, this)
    @collection.on('add', @appendEpisodeAndUpdateCount, this)
    @collection.on('remove', @renderEpisodeRemoved, this)

  # Internal: Called when view is being closed, gets rid of events and disposes
  # of children properly.
  #
  # Returns nothing.
  onClose: ->
    @closeChildren()
    @collection.off('reset', @render)
    @collection.off('add', @appendEpisodeAndUpdateCount)
    @collection.off('remove', @renderEpisodeRemoved)

  events:
    'click .js-show-create-episode':  'showCreateEpisode'

  render: ->
    @$el.html(@template(
      showTitle: Showgap.Show.get('title')
      showDescription: Showgap.Show.get('description')
      episodesSubtitle: @collection.stringCount()
      hasEpisodes: !@collection.isEmpty()
      createButtonClass: if @collection.isEmpty() then 'btn-large btn-primary'
    ))
    @renderEpisodeList()

    this

  # Internal: Render the episodes in their container and dispose of the old
  # views properly.
  #
  # Returns nothing.
  renderEpisodeList: ->
    @closeChildren()
    @collection.each(@appendEpisode)
    @$('.episode-count').text @collection.stringCount()


  # Internal: Properly dispose of the child views and reset the tracking array.
  #
  # Returns nothing.
  closeChildren: ->
    @childViews.each (childView) ->
      childView.close()

    @childViews = _([])

  # -----------------------
  # Helpers
  # -----------------------

  # Internal: Appends a episode view item to the episode list by passing the
  # template a episode model.
  #
  # episode - An Episode model, duh.
  #
  # Returns nothing.
  appendEpisode: (episode) =>
    view = new Showgap.Views.EpisodesListShow(model: episode)
    @childViews.push view
    @$('.episode-list').append(view.render().el)

  renderEpisodeRemoved: (episode) =>
    if @collection.length == 0
      # We removed the last episode, render the entire view so we can see the
      # empty state.
      @render()
    else
      # We removed an episode, but there are more left, just re-render the
      # episode list.
      @renderEpisodeList()

  # Internal: Updates the episode count after calling appendEpisode.
  #
  # Returns nothing.
  appendEpisodeAndUpdateCount: (episode) =>
    if @collection.length == 1
      # We just made our first episode, we need to rerender the entire view.
      @render()
    else
      # Trigger a full render by sorting the collection.
      @collection.sort()
      @$('.episode-count').text @collection.stringCount()

  # -----------------------
  # User-Initiated Events
  # -----------------------

  # Internal: Shows the create episode form.
  #
  # Returns nothing.
  showCreateEpisode: (event) =>
    event.preventDefault()

    form = new Showgap.Views.FormsShow(
      el: @$('.episode-form-wrapper')[0]
      className: 'episode-form'
      modelClass: Showgap.Models.Episode
      $viewToHide: @$('.js-show-create-episode')
      collection: @collection
      extraAttributes:
        show: @show
      saveButtonText: 'Create Episode'
      showFooterHelp: true
      title: 'Create an Episode'
    ).render()
