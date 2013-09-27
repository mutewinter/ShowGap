class Showgap.Collections.Discussions extends Backbone.Collection
  url: '/api/discussions'
  model: Showgap.Models.Discussion

  # -----------------------
  # View Helpers
  # -----------------------
  discussionsAmountText: ->
    if @length == 1
      discussionsPluralized = 'discussion'
    else
      discussionsPluralized = 'discussions'

    "#{@length} #{discussionsPluralized}"
