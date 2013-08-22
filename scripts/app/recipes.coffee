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
      'focus': '_select'

    _select: ->
      @model.set 'selected', true

  class NoRecipesView extends Marionette.ItemView
    className: 'no-recipes-message'
    template: '<span>no recipes :(</span>'

  class ListView extends NavigableList.ListView
    itemView: ItemView
    emptyView: NoRecipesView

    collectionEvents:
      'change:selected': '_enforceSingleSelected'

    _enforceSingleSelected: (model, selected) ->
      if selected
        _.chain(@collection.models)
          .filter((m) -> m.get('selected'))
          .without(model)
          .each((m) -> m.set 'selected', false)

  return {
    Model: Model
    ListView: ListView
  }
