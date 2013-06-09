exports = window.inspect ?= {}

class exports.InspectModel extends Backbone.Model
  defaults: ->
    drink: null

_conversions =
  q: 'quantity'
  u: 'unit'

# TODO: Rename this -- it isn't reeeeally format.
# TODO: Also, can this be cleaned up? It's kind of gross string manipulation.
_formatDrink = (d) ->
  ingredients = []
  for ingredient in d.ingredients
    {text, tag} = ingredient
    prev = { i: 0, j: -1}
    splitIngredient = []
    while prev.i != -1
      curr = {}
      curr.i = text.indexOf '{', prev.j
      curr.j = text.indexOf '}', curr.i
      splitIngredient.push text.substring prev.j + 1, (if curr.i != -1 then curr.i else text.length)
      if curr.i != -1 and curr.j != -1
        piece = {}
        piece[_conversions[text[curr.i + 1]]] = text.substring curr.i + 2, curr.j
        splitIngredient.push piece
      prev = curr
    ingredients.push splitIngredient
  console.log ingredients
  return _.defaults { ingredients: ingredients }, d

class exports.InspectView extends Backbone.View
  className: 'inspect-view'

  initialize: ->
    @listenTo @model, 'change:drink', @render

  render: ->
    if not @model.get 'drink'
      @$el.html Handlebars.templates['inspect-empty']()
    else
      @$el.html Handlebars.templates['inspect'] _formatDrink @model.get('drink').attributes

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
