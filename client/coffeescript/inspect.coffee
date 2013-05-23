exports = window.inspect ?= {}

class exports.InspectModel extends Backbone.Model
  defaults: ->
    drink: null

class exports.InspectView extends Backbone.View
  className: 'inspect-view'

  initialize: ->
    @listenTo @model, 'change:drink', @render

  render: ->
    if not @model.get 'drink'
      @$el.html Handlebars.templates['inspect-empty']()
    else
      @$el.html Handlebars.templates['inspect'] @model.get('drink')

# No options yet.
exports.bundle = (options) ->
  options ?= {}
  model = new exports.InspectModel
  view = new exports.InspectView
    model: model
  return {
    model: model
    view: view
  }
