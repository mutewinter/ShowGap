# Application-wide routes files
#
# Handles index route and invalid routes.
class Showgap.Routers.Application extends Backbone.Router
  routes:
    '':                                   'index'
    'login':                              'login'
    'episodes/:id':                       'episodeShow'
    'episodes/:id/discussions/:id/edit':  'discussionEdit'
    'episodes/:id/discussions/:id':       'discussionShow'
    '*default':                           'default'

  initialize: (options) ->
    @episodes = options.episodes
    @show = options.show

  # -----------------------
  # Variables
  # -----------------------
  $el: $('#container')

  # -----------------------
  # Show Routes
  # -----------------------

  # Internal: Show the detailed view for a given episode id.
  #
  # id - Integer id of a valid episode in the @episodes collection.
  #
  # Returns nothing.
  episodeShow: (id) ->
    model = @episodes.get(id)
    view = new Showgap.Views.EpisodesShow(
      model: model
    )
    @swapView(view)

  # -----------------------
  # Discussion Routes
  # -----------------------

  # Internal: Show the detailed view for a discussion.
  #
  # episodeId    - Integer id of a valid episode in the @episodes collection.
  # discussionId - Integer id of a valid discussion in the
  #                @episodes.get('discussions') collection.
  #
  # Returns nothing.
  discussionShow: (episodeId, discussionId) ->
    episode = @episodes.get(episodeId)
    discussion = episode.get('discussions').get(discussionId)

    view = new Showgap.Views.EpisodesShow(
      model: episode
      selectedDiscussion: discussion
    )
    @swapView(view)

  # Internal: Show the discussion in edit mode.
  #
  # episodeId    - Integer id of a valid episode in the @episodes collection.
  # discussionId - Integer id of a valid discussion in the
  #                @episodes.get('discussions') collection.
  #
  # Returns nothing.
  discussionEdit: (episodeId, discussionId) ->
    episode = @episodes.get(episodeId)
    discussion = episode.get('discussions').get(discussionId)

    # Unauthorized user, switch to discussion episode instead.
    unless Showgap.User.can('manage', 'discussion')
      Backbone.history.navigate(discussion.clientUrl(), trigger: true)
      return

    view = new Showgap.Views.EpisodesShow(
      model: episode
      selectedDiscussion: discussion
      discussionEditMode: true
    )
    @swapView(view)

  # -----------------------
  # General Routes
  # -----------------------

  # Displays a list of episodes and also episodes the flash error if one exists.
  #
  # Returns nothing.
  index: ->
    # TODO
    # Clear these error messages as soon as the user navigates away
    # or perhaps on a timer
    if Showgap.flash.error?
      console.error "Got errors #{Showgap.flash.error}"
      $errorAlert = $(
        "<div class='alert alert-error'>
          <a class='close' data-dismiss='alert' href='#'>x</a>
          <strong>Dagnabbit.</strong> #{Showgap.flash.error}
          <ul class='errors'></ul>
        </div>"
      )
      $('body').prepend($errorAlert)
      Showgap.flash.error = null

    view = new Showgap.Views.EpisodesIndex(
      collection: @episodes
      show: @show
    )
    @swapView(view)

  login: ->
    $('#container').html '<a href="/auth/twitter/login">Login</a>'

  # Route not found, redirect to homepage and display an error message.
  #
  # Returns nothing.
  default: (args) ->
    console.error "Landed on invalid route #{args}"
    Showgap.flash.error = "Invalid Route #{args}"
    Backbone.history.navigate('/', trigger: true)

  # -----------------------
  # Helpers
  # -----------------------

  # Internal: Swaps the current view with the new view, disposing of the old
  # view properly.
  # Credit to Backbone.js on Rails http://bit.ly/HIAqYW
  #
  # Returns nothing.
  swapView: (newView) ->
    if @currentView
      @currentView.close()

    @currentView = newView
    @$el.empty().html(newView.render().el)
