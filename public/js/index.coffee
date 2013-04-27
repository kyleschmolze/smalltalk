$(document).ready ->
  App.Views.index = new App.Views.Index()
  App.Collections.items = new App.Collections.Items()

class App.Views.Index extends Backbone.View
  initialize: ->
    console.log 'init index!'
