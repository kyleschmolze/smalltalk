class App.Collections.Items extends Backbone.Collection
  initialize: ->
    socket = io.connect()
    socket.on 'new-item', (data) =>
      this.add new App.Models.Item
        title: data.msg
        description: 'some more stuff'

class App.Models.Item extends Backbone.Model
  initialize: ->
    this.view = new App.Views.Item model: this
    true

class App.Views.Item extends Backbone.View
  tagName: 'li'

  events:
    'click': ->
      console.log 'click'

  initialize: ->
    this.render()

  render: ->
    this.$el.html _.template $("#item-view").html(), this.model.toJSON()
    $("ul").prepend this.el
