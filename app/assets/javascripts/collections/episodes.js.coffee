class Showgap.Collections.Episodes extends Backbone.Collection
  url: '/api/episodes'
  model: Showgap.Models.Episode

  # Internal: Default comparitor used for sorting episodes.
  #
  # Returns object on which to sort the collection.
  comparator: (episode) ->
    if episode.recordDate()
      # Negative epoch time will sort newest to the top.
      -episode.recordDate().getTime()
    else
      0

  # -----------------------
  # Helpers
  # -----------------------

  # Public: Return the properly pluralized count of episodes.
  stringCount: ->
    "#{@length} #{if @length == 1 then 'Episode' else 'Episodes'}"

  # Public: Retreive the next chronological episode based on the episode
  # passed. Note, the next chronological episode is the previous one in the
  # array due to the collection always being sorted in reverse chronological
  # order.
  #
  # episode - An Episode model.
  #
  # Returns the episode model following or null if no episode is found.
  followingEpisode: (episode) ->
   nextEpisodeIndex = @indexOf(episode) - 1
   @at(nextEpisodeIndex ) if nextEpisodeIndex >= 0

  # Public: The same as followingEpisode except looking backward.
  #
  # episode - An Episode model.
  #
  # Returns the episode model following or null if no episode is found.
  precedingEpisode: (episode) ->
   previousEpisodeIndex = @indexOf(episode) + 1
   @at(previousEpisodeIndex) if previousEpisodeIndex < @length
