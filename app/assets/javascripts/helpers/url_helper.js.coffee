# Public: Adds a Url object that handles Url display using URI.js.
Showgap.Helpers.Url =
  # Public: Removes the protocol, subdomain if it's www, and :// from a given
  # url string or URI.js object.
  #
  # url - The url string or URI.js object to have its protocol removed.
  #
  # Returns the url string without the protocol.
  shortReadableUrl: (url) ->
    # Don't try to process an undefined url. Note: an undefined url results in
    # a url for the page this call happens on. Yea, that's crazy.
    return unless url

    url = URI(url) if _.isString url
    stringUrl = url.toString()

    if url.subdomain() == 'www'
      url.subdomain('')

    if url.protocol() == 'http' or url.protocol() == 'https'
      stringUrl = url.protocol(null).toString()
        .slice(2, url.length)

    stringUrl

  # Public: Sanitizes a url by running URI.normalize and appending http:// if
  # necessary.
  #
  # url - The url string or URI.js object that needs to be sanitized.
  #
  # Returns the sanitized url string unless the url is blank, then the empty
  #   string is returned.
  sanitizeUrl: (url) ->
    url = URI(url) if _.isString url
    if url.toString() == ''
      return url.toString()
    if url.protocol()
      url.normalize().toString()
    else
      "http://#{url.normalize().toString()}"
