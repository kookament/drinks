define [ 'underscore'
         'marionette'
         'cs!./navigable-list'
         'cs!./filterable-decorator'
         'cs!./ingredients'
         'cs!./recipes'
         'cs!./instructions'
         'cs!./recipe-search'
         'cs!./persistence'
         'cs!./derivative-search'
         'less!../styles/app.less' ],
(_
 Marionette
 NavigableList
 filterableDecorator
 Ingredients
 Recipes
 Instructions
 RecipeSearch
 Persistence
 DerivativeSearch) ->
  # how many ingredients you can be missing and still have something come up
  _FUDGE_FACTOR = 2

  return ->
    # initialize regions
    app = new Marionette.Application

    app.addRegions
      ingredients: '#ingredients'
      drinks: '#drinks'
      instructions: '#instructions'

    # initialize global state
    search = new Ingredients.SearchModel

    ingredients = RecipeSearch.ingredients.map (n) -> { tag: n }

    ingredients = new Backbone.Collection ingredients,
      model: Ingredients.Model

    searchedIngredients = filterableDecorator ingredients

    availableFilter = (m) -> m.get('available')
    availableIngredients = filterableDecorator ingredients
    availableIngredients.filter(availableFilter)

    recipes = new Backbone.Collection [],
      model: Recipes.Model

    # initialize glue code
    derivativeController = _.extend {}, Backbone.Events
    derivativeController.listenTo ingredients, 'change:implied', _.debounce (
      -> availableIngredients.filter(availableFilter)
    ), 0
    # this was originally debounced but that broke local storage loading: is it a performance problem?
    derivativeController.listenTo ingredients, 'change:selected', (model, selected) ->
      availableIngredients.filter(availableFilter)
      have = availableIngredients.pluck 'tag'
      if selected
        additions = DerivativeSearch.computeAdditions model.get('tag'), have
        for m in ingredients.filter((m) -> m.get('tag') in additions)
          m.set 'implied', true
      else
        removals = DerivativeSearch.computeRemovals model.get('tag'), have
        for m in ingredients.filter((m) -> m.get('tag') in removals)
          m.set 'implied', false

    searchController = _.extend {}, Backbone.Events
    searchController.listenTo search, 'change:search', -> search.set { loading: true }
    searchController.listenTo(search, 'change:search', _.debounce (
      ->
        searchedIngredients.filter(
          Ingredients.generateIngredientMatcher(search.get('search'))
        )
        search.set { loading: false }
      ), 150
    )
    searchController.listenTo availableIngredients, 'add remove reset', ->
      newRecipes = RecipeSearch.find(availableIngredients.pluck('tag'), _FUDGE_FACTOR)
      newRecipes = _.chain(newRecipes).sortBy('name').sortBy('missing').value()
      lastMissing = -1
      i = 0
      while i < newRecipes.length # we use a while because we'll be adding stuff
        missing = newRecipes[i].missing
        if missing > lastMissing
          text = switch missing
            when 0 then 'mixable drinks'
            when 1 then '...with 1 more ingredient'
            else "...with #{missing} more ingredients"
          newRecipes.splice i, 0, new NavigableList.HeaderModel { text: text }
          lastMissing = missing
          i++
        i++
      recipes.reset newRecipes

    # this is gross but I need to have $scrollContainer for below
    app.drinks.ensureEl()

    # initialize views
    mixableRecipesView = new Recipes.ListView
      collection: recipes
      $scrollContainer: app.drinks.$el

    ingredientsSearchView = new Ingredients.SearchSidebar
      model: search
      collection: searchedIngredients
      rightArrowKey: -> mixableRecipesView.enterTop()

    # initialize more glue code for views
    mixableRecipesView.left = ->
      ingredientsSearchView.search.currentView.focusInput()

    searchController.listenTo mixableRecipesView, 'activate', ->
      ingredientsSearchView.list.currentView.deselect()

    searchController.listenTo recipes, 'change:selected remove reset', _.debounce (->
      selected = recipes.findWhere { selected: true }
      if selected
        app.instructions.show(new Instructions.View
          model: selected
          available: availableIngredients
        )
      else
        app.instructions.show(new Instructions.EmptyView)
    ), 0

    # initialize persistence
    persistence = new Persistence.Ingredients
      ingredients: ingredients
    persistence.load()

    # initialize go
    app.start()

    app.ingredients.show(ingredientsSearchView)
    app.drinks.show(mixableRecipesView)
    app.instructions.show(new Instructions.EmptyView)

    $('input.search-input').focus()

    $(window).keydown (ev) ->
      if ev.which == 38 or ev.which == 40 # arrow up, arrow down
        if recipes.length
          mixableRecipesView.grabFocus()
        else if searchedIngredients.length
          ingredientsSearchView.list.currentView.grabFocus()
        else
          ingredientsSearchView.search.currentView.focusInput()

    return app
