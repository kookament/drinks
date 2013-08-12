define [ 'backbone' ],
(Backbone) ->
  class Drink extends Backbone.Model
    defaults: ->
      name: ''
      tags: []
      ingredients: []
      instructions: ''
      notes: ''

  return Drink