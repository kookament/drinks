define [ 'backbone'
         'marionette'
         'cs!./navigable-list'
         'hbs!../templates/recipe-list-item'
         'less!../styles/recipes' ],
(Backbone, Marionette, NavigableList, recipe_list_item) ->
  class Model extends Backbone.Model
    defaults: ->
      name: ''
      ingredients: []
      instructions: ''
      notes: ''

  class ItemView extends NavigableList.ItemView
    className: -> super + ' recipe'
    template: recipe_list_item

    events:
      'navigate-active': '_select'
      'navigate-inactive': '_deselect'

    _select: ->
      @model.set 'selected', true

    _deselect: ->
      @model.set 'selected', false

  class NoRecipesView extends Marionette.ItemView
    className: 'no-recipes-message'
    template: '<span>no recipes :(</span>'

  class ListView extends NavigableList.ListView
    itemView: ItemView
    emptyView: NoRecipesView

  return {
    Model: Model
    ListView: ListView
  }
