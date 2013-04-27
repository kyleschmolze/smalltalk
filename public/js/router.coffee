class App.Router extends Backbone.Router
  routes:
    "": "index"
    "item/:cid": "item"

  index: ->
    console.log 'index'
    $(".feed").show()
    $(".details").hide()

  item: (cid) ->
    $(".feed").hide()
    $(".details").show()
    App.Collections.items.details_view.render(cid)
