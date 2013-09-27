class Showgap.Models.User extends Backbone.RelationalModel
  clientUrl: -> "users/#{@id}"
  isAdmin: ->
    @get('role') == 'admin'
  isHost: ->
    @get('role') == 'host'
  isListener: ->
    @get('role') == 'listener'
