define [
  'backbone'
  'marionette'
  'cs!../app/filterable-decorator'
  'cs!../app/recipe-search'
  'cs!../app/persistence'
  'cs!../app/ingredients'
  'cs!../app/navigable-list'
  'cs!../app/selectable-list'
  'hbs!../templates/default-ingredient-list-item'
], (
  Backbone
  Marionette
  filterableDecorator
  RecipeSearch
  Persistence
  Ingredients
  NavigableList
  SelectableList
  defaultIngredientListItemTemplate
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

    return {
      app
      ingredients
      availableIngredients
    }

  initializePersistence = (globals) ->
    new Persistence.Ingredients(ingredients : globals.ingredients).load()
    globals.availableIngredients.filter()

  initializeViews = (globals) ->
    globals.app.body.show new NavigableList.ListView
      collection : globals.ingredients
      itemView   : class L extends SelectableList.ItemView
        template : defaultIngredientListItemTemplate

  return ->
    globals = initializeGlobals()
    initializePersistence(globals)
    initializeViews(globals)

    globals.app.start()

    return globals
