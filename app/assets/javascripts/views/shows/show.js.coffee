class Showgap.Views.ShowsShow extends Backbone.View
  template: JST['shows/show']

  initialize: ->
    @model.on('change', @render, this)
    @model.on('remove:discussions', @discussionDeleted, this)

  render: ->
    if @model
      @$el.html(@template(
        name: @model.get('name')
        description: @model.get('description')
      ))

      @detailView = new Showgap.Views.DiscussionsShow(
        model: @options.selectedDiscussion
        editMode: @options.discussionEditMode
      )
      @$('#discussion-detail').html(@detailView.render().el)

    # Render the discussions
    discussionsView = new Showgap.Views.DiscussionsIndex(
      collection: @model.get('discussions')
      show: @model
    )

    @$('#discussions').html(discussionsView.render().el)

    this

  discussionDeleted: (discussion) ->
    if discussion == @detailView.model
      @detailView.close()
