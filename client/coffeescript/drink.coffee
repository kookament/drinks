exports = window.drink ?= {}

class exports.Drink extends Backbone.Model
  defaults: ->
    name: ''
    tags: []
    ingredients: []
    instructions: ''
    notes: ''
    missing: 0
