define [ 'backbone'
         'marionette'
         'hbs!../templates/recipe-list-item' ],
(Backbone, Marionette, recipe_list_item) ->
  class Model extends Backbone.Model
    defaults: ->
      name: ''
      ingredients: []
      instructions: ''
      notes: ''

  class ItemView extends Marionette.ItemView
    className: 'recipe-list-item'
    template: recipe_list_item

  class NoRecipesView extends Marionette.ItemView
    className: 'no-recipes-message'
    template: '<span>no recipes :(</span>'

  class ListView extends Marionette.CollectionView
    className: 'recipes-list'
    itemView: ItemView
    emptyView: NoRecipesView

  return {
    Model: Model
    ListView: ListView
  }
