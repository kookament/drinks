define [ 'underscore'
         'marionette'
         'cs!./ingredients'
         'cs!./search-list'
         'cs!./filterable-decorator' ],
(_, Marionette, Ingredient, SearchList, filterableDecorator) ->
  return ->
    app = new Marionette.Application

    app.addRegions
      ingredients: '#search-sidebar'
      drinks: '#search-results'
      instructions: '#instructions'

    search = new Ingredient.SearchModel

    ingredients = [
      'gin'
      'ginger'
      'ginger beer'
      'cachaca'
    ].map (n) -> { name: n }

    ingredients = new Backbone.Collection ingredients,
      model: Ingredient.Model

    filteredIngredients = filterableDecorator ingredients
    filteredIngredients.filter()

    searchController = _.extend {}, Backbone.Events
    searchController.listenTo search, 'change:search', -> search.set { loading: true }
    searchController.listenTo(search, 'change:search', _.debounce (
      ->
        filteredIngredients.filter(
          Ingredient.generateIngredientMatcher(search.get('search'), 'name')
        )
        search.set { loading: false }
      ), 150
    )

    searchSidebar = new Ingredient.Sidebar
      search: search
      collection: filteredIngredients

    app.start()

    app.ingredients.show(searchSidebar)

    return app
