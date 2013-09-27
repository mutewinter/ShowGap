class Showgap.Models.Episode extends Backbone.RelationalModel
  urlRoot: -> '/api/episodes'
  clientUrl: -> "episodes/#{@id}"

  # Internal: Sugar.js long date format.
  longDateFormat: '{Month} {ord}, {yyyy} at {12hr}:{mm} {tt}'
  # Internal: Sugar.js short date format.
  shortDateFormat: '{Month} {ord}, {yyyy}'

  relations: [
    type: Backbone.HasMany
    key: 'discussions'
    relatedModel: 'Showgap.Models.Discussion'
    collectionType: 'Showgap.Collections.Discussions'
    reverseRelation:
      key: 'episode'
      includeInJSON: 'id'
      keyDestination: 'episode_id'
  ]

  schema:
    title:
      type: 'Text'
      validators: [
        type: 'required'
        message: "Give your episode a title or I'll call it Barbie's Horse Adventure 7."
      ]
      placeholder: "That's Fine for Buddha"
    record_date:
      type: 'Kalendae'
      title: 'Record Date'
      template: 'kalendae'
      placeholder: Date.create('one week from now').format('{M}/{d}')
      validators: [
        (value, formValues) ->
          error =
            type: 'record_date'
            message: "Hmm, that doesn't look like a date to me."

          # We've got an object, and it's either not a date or registers as an
          # invalid date.
          return error if value and (!_.isDate(value) or !value.isValid())
      ]

  # -----------------------
  # Helpers
  # -----------------------

  questions: -> @get('discussions').where(discussion_type: 'question')
  polls: -> @get('discussions').where(discussion_type: 'poll')


  # Public: Get the Date object for the record date of this episode.
  #
  # Returns the Date object for the record date or null if the record_date is
  #   not defined for this model.
  recordDate: ->
    if @get('record_date')
      Showgap.Memoized.isoToDate @get('record_date')
    else
      null

  # Public: Get the title for this epsiode, adding the word "Episode" if the
  # title is only a number.
  #
  # Returns the episode String title.
  episodeTitle: ->
    title = @get('title')
    slug = @get('slug')

    if title
      if title.match(/^[0-9]+$/)
        "Episode #{title}"
      else
        title
    else if slug
      # Slug becomes the title since we don't have a title
      if slug.match(/^[0-9]+$/)
        "Episode #{slug}"
      else
        slug.humanize().titleize()
    else
      # No title or slug
      'Untitled Episode'


  # Public: Create the human-readable version of the record date with "Recorded"
  # or "Records" properly prepended.
  #
  # Returns the formatted date string or 'No Record Date' if record_date is
  # empty.
  recordDateLong: ->
    if @get('record_date')
      recordDate = Date.create(@get('record_date'))
      if recordDate.isFuture() or recordDate.isToday()
        recordDatePrefix = 'Records'
      else
        recordDatePrefix = 'Recorded'

      "#{recordDatePrefix} on #{recordDate.format(@longDateFormat)}"
    else
      'No Record Date'

  # Public: Create the short human-readable version of the record date.
  #
  # Returns the formatted date string or 'No Record Date' if record_date is
  # empty.
  recordDateShort: ->
    if @get('record_date')
      recordDate = Date.create(@get('record_date'))
      recordDate.format(@shortDateFormat)
    else
      'No Record Date'
