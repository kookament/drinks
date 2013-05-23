drink = window.drink ?= {}

class drink.Model extends Backbone.Model
  defaults: ->
    drink: null

class drink.View extends Backbone.View
  className: 'drink-view'

  initialize: ->
    @listenTo @model, 'change:drink', @render

  render: ->
    @$el.html @model.get('drink').name
