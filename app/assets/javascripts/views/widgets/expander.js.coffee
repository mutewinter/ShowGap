class Showgap.Widgets.Expander extends Backbone.View
  template: JST['application/expander']
  className: 'expander'

  events: ->
    'click .js-expand': 'expandClicked'

  initialize: (options) ->
    @text = options.text

  render: ->
    @$el.html(@template(
      text: @text
      expanded: @options.expanded
    ))

    # Try to add the expander now if we're already visible.
    if @$el.is(':visible')
      @addExpander()
    else
      # This is the first render, we need to do this after the render is done.
      _.defer @addExpander

    this

  addExpander: =>
   if @expanderNeeded()
    @$('.expand-fader').removeClass('hidden')
    if @options.expanded
      @$('.expand-button').click()

  expanderNeeded: ->
    linesOfText = @linesOfText()
    !_.isNaN(linesOfText) and (linesOfText > @options.maximumLines)

  # Internal: Calculates the number of lines in the .expand-text div.
  #
  # Returns the integer number of lines of text in the div.
  linesOfText: ->
    $element = @$('.expand-text')
    if $element.length
      height = $element.height()
      lineHeight = parseInt $element.css('line-height').replace('px', '')
      Math.ceil height / lineHeight

  expandClicked: (event) =>
    event.preventDefault()
    if @$('.expand-text').hasClass('show')
      @collapse()
    else
      @expand()

  expand: ->
    @$('.expand-text').addClass('show')
    @$('.expand-button .text').text('Collapse')
    @$('.expand-button i').removeClass('icon-plus')
    @$('.expand-fader').addClass('no-fade')
    @$('.expand-button i').addClass('icon-minus')

  collapse: ->
    @$('.expand-text').removeClass('show')
    @$('.expand-button .text').text('Expand')
    @$('.expand-button i').removeClass('icon-minus')
    @$('.expand-button i').addClass('icon-plus')
    @$('.expand-fader').removeClass('no-fade')
