define [
  'backbone'
  'marionette'
  'cs!../app/filterable-decorator'
  'cs!../app/recipe-search'
  'cs!../shared/recipe-search-results'
  'cs!../app/persistence'
  'cs!../app/ingredients'
  'cs!../app/recipes'
  'cs!../app/navigable-list'
  'hbs!../templates/m/recipe-list-item'
], (
  Backbone
  Marionette
  filterableDecorator
  RecipeSearch
  RecipeSearchResults
  Persistence
  Ingredients
  Recipes
  NavigableList
  recipeListItemTemplate
) ->

  initializeGlobals = ->
    app = new Marionette.Application
    app.addRegions
      body : 'body'

    ingredients = new Backbone.Collection(
      RecipeSearch.ingredients.map((n) -> { tag : n })
      model : Ingredients.Model
    )

    availableIngredients = filterableDecorator(ingredients)
    availableIngredients.filter((m) -> m.get('available'))

    recipes = new Backbone.Collection(
      []
      model : Recipes.Model
    )

    return {
      app
      ingredients
      availableIngredients
      recipes
    }

  initializePersistence = (globals) ->
    new Persistence.Ingredients(ingredients : globals.ingredients).load()
    globals.availableIngredients.filter()
    mixable = RecipeSearchResults.recomputeMixableRecipes(globals.availableIngredients)
    globals.recipes.reset mixable.map((r) ->
      if r.header?
        return new NavigableList.HeaderModel { text : r.header }
      else
        return r
    )

  initializeViews = (globals) ->
    globals.app.body.show  new Recipes.ListView
      collection : globals.recipes
      itemView   : Recipes.MobileItemView

  return ->
    globals = initializeGlobals()
    initializePersistence(globals)
    initializeViews(globals)

    globals.app.start()

    return globals