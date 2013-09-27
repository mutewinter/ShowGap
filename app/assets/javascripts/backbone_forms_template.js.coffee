(->
  Form = Backbone.Form
  Form.setTemplates
    form: JST['forms/form']
    fieldset: JST['forms/fieldset']
    field: JST['forms/field']
    nestedField: JST['forms/nested_field']
    list: JST['forms/list']
    listItem: JST['forms/list_item']
    date: JST['forms/date']
    dateTime: JST['forms/date_time']
    kalendae: JST['forms/kalendae']
    'list.Modal': '<div class="bbf-list-modal">{{summary}}</div>'
  , { error: 'error' }
)()

# Wysihtml5 editor for Backbone.Form
class Backbone.Form.editors.Wysihtml5 extends Backbone.Form.editors.Base
  tagName: 'textarea'

  initialize: (options) ->
    # Call parent constructor
    Backbone.Form.editors.Base.prototype.initialize.call(this, options)

  render: ->
    @setValue(@value)

    # Activate the wysihtml5 editor
    @postRender.bind(this).delay()

    this

  # Internal: Called after the browser gets control again and assuradely after
  # the render function has been called.
  #
  # Returns nothing.
  postRender: ->
    $(@el).wysihtml5(
      emphasis: true
      lists: true
      html: false
      link: true
      image: false
    )

  getValue: -> $(@el).val()

  setValue: (value) -> $(@el).val(@value)

# Kalendae Date Picker for Backbone.Form
class Backbone.Form.editors.Kalendae extends Backbone.Form.editors.Base
  tagName: 'input'
  className: 'date-field'

  initialize: (options) ->
    # Call parent constructor
    Backbone.Form.editors.Base.prototype.initialize.call(this, options)

  render: ->
    @setValue(@value)
    endOfMonth = Date.create('the end of this month')
    daysUntilEndOfMonth = endOfMonth.daysFromNow(new Date())

    # format: null makes moment use fuzzy parsing instead of fixed.
    @$el.kalendae(
      format: null
      months: if daysUntilEndOfMonth <= 7 then 2 else 1
    )

    this

  getValue: ->
    date = ''
    kalendae = @$el.data('kalendae')

    # Ensure we have a kalendae object with a parsed date.
    if kalendae and kalendae.getSelectedRaw()[0]
      date = @$el.data('kalendae').getSelectedRaw()[0].toDate()

      # User is trying to enter a shorthand date (MM/DD)
      if date and @$el.val().length < 5
        date.set(year: Date.create().getFullYear())

    # Ensure we have text in the time field.
    if time = @$el.siblings('.time-field').val()
      time = Date.create(time)
      if date
        # Modfiy the existing date to have the new time.
        date.set(hours: time.getHours(), minutes: time.getMinutes())
      else
        # No day specified, just use today with the given time.
        date = time

    date

  setValue: (value) -> $(@el).val(@value)
