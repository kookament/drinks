define [ 'underscore'
         'marionette'
         'cs!./filterable-decorator'
         'cs!./ingredients'
         'cs!./recipes'
         'cs!./instructions'
         'cs!./recipe-search'
         'less!../styles/app.less' ],
(_, Marionette, filterableDecorator, Ingredients, Recipes, Instructions, RecipeSearch) ->
  return ->
    # initialize regions
    app = new Marionette.Application

    app.addRegions
      ingredients: '#ingredients'
      drinks: '#drinks'
      instructions: '#instructions'

    # initialize global state
    search = new Ingredients.SearchModel

    ingredients = RecipeSearch.ingredients.map (n) -> { name: n }

    ingredients = new Backbone.Collection ingredients,
      model: Ingredients.Model

    searchedIngredients = filterableDecorator ingredients

    selectedFilter = (m) -> m.get('selected')
    selectedIngredients = filterableDecorator ingredients
    selectedIngredients.filter(selectedFilter)

    recipes = new Backbone.Collection [],
      model: Recipes.Model

    # initialize glue code
    searchController = _.extend {}, Backbone.Events
    searchController.listenTo ingredients, 'change:selected', -> selectedIngredients.filter(selectedFilter)
    searchController.listenTo search, 'change:search', -> search.set { loading: true }
    searchController.listenTo(search, 'change:search', _.debounce (
      ->
        searchedIngredients.filter(
          Ingredients.generateIngredientMatcher(search.get('search'), 'name')
        )
        search.set { loading: false }
      ), 150
    )
    searchController.listenTo selectedIngredients, 'add remove reset', ->
      recipes.reset RecipeSearch.find(selectedIngredients.pluck('name'), 1)

    # initialize views
    mixableRecipesView = new Recipes.ListView
      collection: recipes

    ingredientsSearchView = new Ingredients.SearchSidebar
      model: search
      collection: searchedIngredients
      rightArrowKey: -> mixableRecipesView.enterTop()

    mixableRecipesView.left = ->
      @deselect()
      ingredientsSearchView.search.currentView.focusInput()

    searchController.listenTo mixableRecipesView, 'activate', ->
      ingredientsSearchView.list.currentView.deselect()

    searchController.listenTo ingredientsSearchView, 'activate', ->
      mixableRecipesView.deselect()

    searchController.listenTo recipes, 'change:selected remove reset', _.debounce (->
      selected = recipes.findWhere { selected: true }
      if selected
        app.instructions.show(new Instructions.View
          model: selected
        )
      else
        app.instructions.show(new Instructions.EmptyView)
    ), 0

    # initialize go
    app.start()

    app.ingredients.show(ingredientsSearchView)
    app.drinks.show(mixableRecipesView)
    app.instructions.show(new Instructions.EmptyView)

    $('input.search-input').focus()

    return app
