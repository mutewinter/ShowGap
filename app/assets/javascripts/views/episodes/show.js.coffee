class Showgap.Views.EpisodesShow extends Backbone.View
  template: JST['episodes/show']

  initialize: ->
    @model.on('change', @render, this)
    @model.on('remove:discussions', @discussionDeleted, this)
    @episodes = @model.get('show')?.get('episodes')


  # Internal: Render the discussion list and the discussion detail view.
  #
  # Returns the view itself.
  render: ->
    if @model
      if episode = @episodes.followingEpisode(@model)
        nextEpisode =
          date: episode.recordDateShort()
          url: episode.clientUrl()
      if episode = @episodes.precedingEpisode(@model)
        previousEpisode =
          date: episode.recordDateShort()
          url: episode.clientUrl()

      @$el.html(@template(
        title: @model.episodeTitle()
        recordDate: @model.recordDateLong()
        isoRecordDate: @model.get('record_date')
        nextEpisode: nextEpisode
        previousEpisode: previousEpisode
      ))

      # Use the passed in selected discussion or the first one if none is
      # specified.
      if @options.selectedDiscussion
        selectedDiscussion = @options.selectedDiscussion
      else
        selectedDiscussion = @model.get('discussions').first()

      @detailView = new Showgap.Views.DiscussionsShow(
        model: selectedDiscussion
        editMode: @options.discussionEditMode
      )
      @$('#discussion-detail').html(@detailView.render().el)

    # Render the discussions
    discussionsView = new Showgap.Views.DiscussionsIndex(
      collection: @model.get('discussions')
      episode: @model
    )

    @$('#discussions').html(discussionsView.render().el)

    # Handle scroll events so we can sticky the discussion list when we scroll
    # it off screen.
    @$('#discussions').waypoint (event, direction) =>
      # When the window is too small, the fixed div will overlap our content.
      if @$('.content').width() > $(window).width()
        # Window is too small, make sure we're not fixed.
        $('#discussions')
          .parent('.column').removeClass('fixed', direction == 'down')
        $('#discussion-detail')
          .parent('.column').removeClass('offset6', direction == "down")
      else
        $('#discussions')
          .parent('.column').toggleClass('fixed', direction == 'down')
        $('#discussion-detail')
          .parent('.column').toggleClass('offset6', direction == "down")

      event.stopPropagation()

    this

  # Internal: Close the detail view for the deleted discussion if it's open.
  #
  # Returns nothing.
  discussionDeleted: (discussion) ->
    if discussion == @detailView.model
      @detailView.close()
