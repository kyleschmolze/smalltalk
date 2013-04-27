$(document).ready ->
  App.Views.index = new App.Views.Index()
  App.Collections.items = new App.Collections.Items()
  App.router = new App.Router()
  Backbone.history.start()

class App.Views.Index extends Backbone.View
  initialize: ->
    console.log 'init index!'
