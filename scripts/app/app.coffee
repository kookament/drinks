define [ 'underscore'
         'marionette'
         'cs!./navigable-list'
         'cs!./filterable-decorator'
         'cs!./ingredients'
         'cs!./recipes'
         'cs!./instructions'
         'cs!./persistence'
         'cs!./recipe-search'
         'cs!./derivative-search'
         'json!../data/sources.json'
         'less!../styles/app.less' ],
(_
 Marionette
 NavigableList
 filterableDecorator
 Ingredients
 Recipes
 Instructions
 Persistence
 RecipeSearch
 DerivativeSearch
 sources) ->
  # how many ingredients you can be missing and still have something come up
  _FUDGE_FACTOR = 2
  _GLASS_REGEX = /\{g([^\{]*)\}/

  initApp = ->
    app = new Marionette.Application

    app.addRegions
      ingredients: '#ingredients'
      drinks: '#drinks'
      instructions: '#instructions'

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

    return {
      app: app
      search: search
      ingredients: ingredients
      searchedIngredients: searchedIngredients
      availableIngredients: availableIngredients
      recipes: recipes
    }

  initPersistence = (globals) ->
    persistence = new Persistence.Ingredients
      ingredients: globals.ingredients
    persistence.load()

  initDerivatives = (globals) ->
    have = globals.ingredients.pluck 'tag'
    _.chain(have)
      .map((i) -> DerivativeSearch.computeAdditions i, have)
      .flatten(true)
      .each((i) -> globals.ingredients.findWhere(tag: i)?.set 'implied', true)
    globals.availableIngredients.filter()

    derivativeController = _.extend {}, Backbone.Events
    derivativeController.listenTo globals.ingredients, 'change:implied', _.debounce (
      -> globals.availableIngredients.filter()
    ), 0
    derivativeController.listenTo globals.ingredients, 'change:selected', _.debounce((model, selected) ->
      globals.availableIngredients.filter()
      have = globals.availableIngredients.pluck 'tag'
      if selected
        additions = DerivativeSearch.computeAdditions model.get('tag'), have
        for m in globals.ingredients.filter((m) -> m.get('tag') in additions)
          m.set 'implied', true
      else
        removals = DerivativeSearch.computeRemovals model.get('tag'), have
        for m in globals.ingredients.filter((m) -> m.get('tag') in removals)
          m.set 'implied', false
    ), 0

  initSearch = (globals) ->
    resetRecipes = ->
      newRecipes = RecipeSearch.find(globals.availableIngredients.pluck('tag'), _FUDGE_FACTOR)
      newRecipes = _.chain(newRecipes).sortBy('name').sortBy('missing').value()

      for r in newRecipes
        if sources[r.source]
          r.source =
            name: sources[r.source].name
            url: r.url ? sources[r.source].url
        # ignore the {g} directive for now
        r.instructions = r.instructions.replace _GLASS_REGEX, '$1'

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

      globals.recipes.reset newRecipes

    resetRecipes()

    searchController = _.extend {}, Backbone.Events
    searchController.listenTo(globals.search, 'change:search', _.debounce (
      ->
        globals.searchedIngredients.filter(
          Ingredients.generateIngredientMatcher(globals.search.get('search'))
        )
      ), 150
    )
    searchController.listenTo globals.availableIngredients, 'add remove reset', resetRecipes

  initViews = (globals) ->
    # we have to initialize these in a weird order cause they reference each other
    globals.app.drinks.ensureEl()
    mixableRecipesView = new Recipes.ListView
      collection: globals.recipes
      $scrollContainer: globals.app.drinks.$el

    ingredientsSearchView = new Ingredients.SearchSidebar
      model: globals.search
      collection: globals.searchedIngredients
      rightArrowKey: -> mixableRecipesView.enterTop()

    mixableRecipesView.left = ->
      ingredientsSearchView.search.currentView.focusInput()

    # catch events when nothing is focused
    $(window).keydown (ev) ->
      if ev.which == 38 or ev.which == 40 # arrow up, arrow down
        if recipes.length
          mixableRecipesView.grabFocus()
        else if searchedIngredients.length
          ingredientsSearchView.list.currentView.grabFocus()
        else
          ingredientsSearchView.search.currentView.focusInput()

    # shove everything into the app
    globals.app.ingredients.show(ingredientsSearchView)
    globals.app.drinks.show(mixableRecipesView)
    globals.app.instructions.show(new Instructions.EmptyView)

    ingredientsSearchView.search.currentView.focusInput()

    # link together some actions between the views
    viewManager = _.extend {}, Backbone.Events
    viewManager.listenTo mixableRecipesView, 'activate', ->
      ingredientsSearchView.list.currentView.deselect()
    viewManager.listenTo globals.recipes, 'change:selected remove reset', _.debounce (->
      selected = globals.recipes.findWhere { selected: true }
      if selected
        globals.app.instructions.show(new Instructions.View
          model: selected
          available: globals.availableIngredients
        )
      else
        globals.app.instructions.show(new Instructions.EmptyView)
    ), 0

  return ->
    globals = initApp()
    initPersistence globals
    initDerivatives globals
    initSearch globals
    initViews globals

    globals.app.start()

    return globals
