define [ 'underscore'
         'backbone'
         'cs!./navigable-list'
         'hbs!../templates/recipe-list-item'
         'less!../styles/recipes' ],
(_
 Backbone
 NavigableList
 recipe_list_item) ->
  class Model extends Backbone.Model
    defaults: ->
      name: ''
      ingredients: []
      instructions: ''
      notes: ''
      source:
        name: ''
        url: ''
      missing: 0

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

  class NoRecipesView extends NavigableList.EmptyView
    template: -> '<td>no recipes :(</td>'

  class ListView extends NavigableList.ListView
    itemView: ItemView
    emptyView: NoRecipesView

    blur: -> # nop: want to keep .active when this happens

  return {
    Model: Model
    ListView: ListView
  }
