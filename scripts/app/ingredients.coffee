define [ 'backbone'
         'marionette'
         'cs!./drink'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-bar' ],
(Backbone, Marionette, Drink, ingredient_list_item, search_bar) ->
  class Model extends Backbone.Model
    defaults:
      name: ''
      aliases: []

  class SearchResult extends Marionette.ItemView
    className: 'ingredient-list-item'
    template: ingredient_list_item

  class SearchModel extends Backbone.Model
    defaults:
      loading: false
      search: ''

  class Sidebar extends Marionette.CompositeView
    className: 'search-sidebar'
    template: search_bar
    itemView: SearchResult

    events:
      'input .search-bar': '_filter'

    constructor: ({@search}) -> super

    _filter: ->
      @search.set 'search', @$('.search-bar').val()

  # todo: clean this code up a bit once the model fields have stabilized
  generateIngredientMatcher = (searchString) ->
    return (m) ->
      if m.get('name').indexOf(searchString) != -1
        return true
      else
        for a in m.get('aliases')
          if a.indexOf(searchString) != -1
            return true
        return false

  return {
    Model: Model
    SearchModel: SearchModel
    SearchResult: SearchResult
    Sidebar: Sidebar
    generateIngredientMatcher: generateIngredientMatcher
  }
