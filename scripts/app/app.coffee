define [ 'underscore'
         'marionette'
         'cs!./ingredients'
         'cs!./filterable-decorator'
         'cs!./recipes'
         'cs!./recipe-search'
         'less!../styles/app.less' ],
(_, Marionette, Ingredient, filterableDecorator, Recipes, RecipeSearch) ->
  return ->
    app = new Marionette.Application

    app.addRegions
      ingredients: '#ingredients'
      drinks: '#drinks'
      instructions: '#instructions'

    search = new Ingredient.SearchModel

    ingredients = RecipeSearch.ingredients.map (n) -> { name: n }

    ingredients = new Backbone.Collection ingredients,
      model: Ingredient.Model

    searchedIngredients = filterableDecorator ingredients

    selectedFilter = (m) -> m.get('selected')
    selectedIngredients = filterableDecorator ingredients
    selectedIngredients.filter(selectedFilter)

    recipes = new Backbone.Collection [],
      model: Recipes.Model

    searchController = _.extend {}, Backbone.Events
    searchController.listenTo ingredients, 'change:selected', -> selectedIngredients.filter(selectedFilter)
    searchController.listenTo search, 'change:search', -> search.set { loading: true }
    searchController.listenTo(search, 'change:search', _.debounce (
      ->
        searchedIngredients.filter(
          Ingredient.generateIngredientMatcher(search.get('search'), 'name')
        )
        search.set { loading: false }
      ), 150
    )
    searchController.listenTo selectedIngredients, 'add remove reset', ->
      recipes.reset RecipeSearch.find(selectedIngredients.pluck('name'), 1)

    ingredientsSearchView = new Ingredient.ListView
      search: search
      collection: ingredients
      searchedCollection: searchedIngredients
      selectedCollection: selectedIngredients

    mixableRecipesView = new Recipes.ListView
      collection: recipes

    app.start()

    app.ingredients.show(ingredientsSearchView)
    app.drinks.show(mixableRecipesView)

    return app
