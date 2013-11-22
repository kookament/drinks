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
         'cs!./tab-switcher'
         'json!../data/sources.json'
         'less!../../styles/app.less' ],
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
 TabSwitcher
 sources) ->
  # how many ingredients you can be missing and still have something come up
  _FUDGE_FACTOR = 2
  _GLASS_REGEX = /\{g([^\{]*)\}/

  initApp = ->
    app = new Marionette.Application

    app.addRegions
      tabs: '#tabs'
      instructions: '#instructions'

    search = new Ingredients.SearchModel

    ingredients = RecipeSearch.ingredients.map (n) -> { tag: n }
    ingredients = new Backbone.Collection ingredients,
      model: Ingredients.Model

    searchedIngredients = new Backbone.Collection [],
      model: Ingredients.MatchModel

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
    have = _.chain(globals.ingredients.models)
      .filter((m) -> m.get 'selected')
      .map((m) -> m.get 'tag')
      .value()
    _.chain(have)
      .map((i) -> DerivativeSearch.computeAdditions i, have)
      .flatten(true)
      .each((i) -> globals.ingredients.findWhere(tag: i)?.set 'implied', true)
    globals.availableIngredients.filter()

    globals.searchedIngredients.reset(
      globals.ingredients.map (m) ->
        return _.defaults { prefix: m.get('tag') }, m.attributes
    )

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
      newRecipes = RecipeSearch.withAny(globals.availableIngredients.pluck('tag'), _FUDGE_FACTOR)
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
        # this is pretty inefficient
        globals.searchedIngredients.reset _.chain(globals.ingredients.models)
          .map(Ingredients.generateIngredientMatcher(globals.search.get('search')))
          .zip(globals.ingredients.models)
          .filter(([match, model]) -> !!match)
          .map(([match, model]) -> new Ingredients.MatchModel _.defaults match, model.attributes)
          .value()
      ), 150
    )
    # propagate selection from us to the backing models
    searchController.listenTo globals.searchedIngredients, 'change:selected', (m) ->
      globals.ingredients.findWhere(tag: m.get('tag')).set 'selected', m.get('selected')
    # accept any and all backing model changes to our displayed models
    searchController.listenTo globals.ingredients, 'change', (m) ->
      globals.searchedIngredients.findWhere(tag: m.get('tag')).set m.changed
    # deboucne to avoid double-updates, which can happen when we add implied ingredients
    searchController.listenTo globals.availableIngredients, 'add remove reset', _.debounce resetRecipes, 25

  initViews = (globals) ->
    # we have to initialize these in a weird order cause they reference each other
    # globals.app.drinks.ensureEl()
    mixableRecipesView = new Recipes.ListView
      collection: globals.recipes
      # $scrollContainer: globals.app.tabs.$el

    ingredientsSearchView = new Ingredients.SearchSidebar
      model: globals.search
      collection: globals.searchedIngredients
      rightArrowKey: ->
        ingredientsSearchView.list.currentView.deselect()
        # mixableRecipesView.enter()

    mixableRecipesView.left = ->
      ingredientsSearchView.search.currentView.focusInput()

    # catch events when nothing is focused
    $(window).keydown (ev) ->
      if ev.which == 38 or ev.which == 40 # arrow up, arrow down
        if globals.recipes.length
          # mixableRecipesView.enter()
          ;
        else if searchedIngredients.length
          ingredientsSearchView.list.currentView.enter()
        else
          ingredientsSearchView.search.currentView.focusInput()

    # shove everything into the app
    tabModel = new Backbone.Model
      options : [
        name : 'Ingredients'
        key  : 'ingredients'
        view : ingredientsSearchView
      ,
        name : 'Recipes'
        key  : 'recipes'
        view : mixableRecipesView
      ]
    tabModel.set 'selected', tabModel.get('options')[0]

    globals.app.instructions.show(new Instructions.EmptyView)
    globals.app.tabs.show new TabSwitcher.TabPaneView
      model : tabModel

    ingredientsSearchView.search.currentView.focusInput()

    # link together some actions between the views
    viewManager = _.extend {}, Backbone.Events
    # viewManager.listenTo mixableRecipesView, 'activate', ->
    #   ingredientsSearchView.list.currentView.deselect()
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

  console.log "Searching #{RecipeSearch.recipes.length} cocktails with #{RecipeSearch.ingredients.length} ingredients."

  return ->
    globals = initApp()
    initPersistence globals
    initDerivatives globals
    initSearch globals
    initViews globals

    globals.app.start()

    return globals
