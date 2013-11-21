define [
  'underscore'
  'backbone'
  'cs!./navigable-list'
  'hbs!../templates/recipe-list-item'
  'hbs!../templates/m/recipe-list-item'
  'less!../styles/recipes'
], (
  _
  Backbone
  NavigableList
  recipeListItemTemplate
  recipeListItemTemplateMobile
) ->
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
    template: recipeListItemTemplate

    events:
      'navigate-active': '_select'
      'navigate-inactive': '_deselect'

    _select: ->
      @model.set 'selected', true

    _deselect: ->
      @model.set 'selected', false

  class MobileItemView extends ItemView
    template : recipeListItemTemplateMobile

  class NoRecipesView extends NavigableList.EmptyView
    template: -> '<td>no recipes :(</td>'

  class ListView extends NavigableList.ListView
    className : -> super + ' recipe-list'
    itemView: ItemView
    emptyView: NoRecipesView

    blur: -> # nop: want to keep .active when this happens

  return {
    Model
    ItemView
    MobileItemView
    ListView
  }
