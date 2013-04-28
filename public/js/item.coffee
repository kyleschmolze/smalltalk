class App.Collections.Items extends Backbone.Collection
  initialize: ->
    socket = io.connect()
    socket.on 'new-item', (data) =>
      console.log data
      this.add new App.Models.Item
        text: data.text
        translatedText: data.translatedText
        wordTranslations: data.translations

    this.details_view = new App.Views.Details
      el: $(".details")
      collection: this


class App.Models.Item extends Backbone.Model
  initialize: ->
    this.view = new App.Views.Item model: this
    true


class App.Views.Item extends Backbone.View
  tagName: 'div'
  className: 'well'

  events:
    'click': -> App.router.navigate "item/#{this.model.cid}", trigger: true

  initialize: ->
    this.render()

  render: ->
    console.log this.model
    this.$el.html _.template $("#item-view").html(), this.model.toJSON()
    $(".list").prepend this.el


class App.Views.Details extends Backbone.View  
  events:
    'click .back': -> App.router.navigate "/", trigger: true
    'keyup input': 'checkWord'
    'click .hint': 'doHint', trigger: false
  
  initialize: (opts) ->
    this.collection = opts.collection

  render: (cid) ->
    this.model = this.collection.get(cid)
    if this.model?
      console.log this.model
      this.$el.find(".info").html _.template($('#details-view').html(), this.model.toJSON())
    else
      this.$el.find(".info").html "<h3><em>Sorry, nothing to see here!</em></h3>"

  checkWord: (event) ->
      input = event.target
      index = $(input).attr('id')
      text = this.model.get('wordTranslations')[index]["translated"]
      if input.value == text
        $(input).parents('.control-group').removeClass('error').addClass('success');
      console.log(text)

    doHint: (event) ->
      button = event.target
      index = $(button).attr('id')
      text = this.model.get('wordTranslations')[index]["translated"]
      $("input##{index}").val(text);
      $("input##{index}").parents('.control-group').removeClass('error').addClass('success');

