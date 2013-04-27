App =
  Views: {}
  Models: {}
  Collections: {}

$(document).ready ->
  App.Views.index = new App.Views.Index()

class App.Views.Index extends Backbone.View
  initialize: ->
    console.log 'init!'
