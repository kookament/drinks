define [ 'backbone'
         'marionette'
         'cs!./drink'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-bar' ],
(Backbone, Marionette, Drink, ingredient_list_item, search_bar) ->
  class IngredientModel extends Backbone.Model
    defaults:
      name: ''
      aliases: []

  class IngredientSearchResult extends Marionette.ItemView
    className: 'ingredient-list-item'
    template: ingredient_list_item

  class IngredientSearch extends Backbone.Model
    defaults:
      search: ''

  class Sidebar extends Marionette.CompositeView
    className: 'search-sidebar'
    template: search_bar
    itemView: IngredientSearchResult

    events:
      'change .search-bar': '_filter'

    _filter: ->
      console.log arguments

  return {
    IngredientModel: IngredientModel
    IngredientSearchResult: IngredientSearchResult
    Sidebar: Sidebar
  }
