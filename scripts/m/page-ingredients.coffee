define [
  'underscore'
  'backbone'
  'marionette'
  'cs!../app/filterable-decorator'
  'cs!../app/recipe-search'
  'cs!../app/persistence'
  'cs!../app/ingredients'
  'cs!../shared/list'
  'cs!../shared/clickable-header'
  'cs!../shared/sticky-header-list'
  'hbs!../templates/default-ingredient-list-item'
  'less!../../styles/m/page-ingredients'
], (
  _
  Backbone
  Marionette
  filterableDecorator
  RecipeSearch
  Persistence
  Ingredients
  List
  ClickableHeader
  StickyHeaderList
  defaultIngredientListItemTemplate
) ->
  class IngredientItemView extends List.ListItemView
    className : -> super + ' ingredient-list-item'
    template  : defaultIngredientListItemTemplate

    ui :
      $icon : '.ingredient-icon-wrapper > i'

    events :
      'click' : '_toggleSelected'

    modelEvents :
      'change:selected' : '_renderSelected'

    onRender : ->
      @_renderSelected()

    _toggleSelected : ->
      @model.set 'selected', not @model.get('selected')

    _renderSelected : ->
      selected = !!@model.get('selected')
      @$el.toggleClass 'selected', selected
      @ui.$icon.toggleClass 'icon-check', selected
      @ui.$icon.toggleClass 'icon-check-empty', not selected

  class PageHeader extends ClickableHeader.View
    collectionEvents :
      'change:selected' : '_updateCounter'

    onShow : ->
      @ui.$right.html 'recipes&nbsp;&#10217;'
      @_updateCounter()

    _updateCounter : ->
      selected = @collection.where({ selected : true }).length
      total = @collection.length
      @ui.$left.text "#{selected}/#{total} ingredients"

    onClick : ->
      window.location = 'recipes.html'

  initializeGlobals = ->
    app = new Marionette.Application
    app.addRegions
      header : '#page-header'
      list   : '#list'

    ingredients = new Backbone.Collection(
      RecipeSearch.ingredients.map((n) -> { tag : n })
      model : Ingredients.Model
    )

    availableIngredients = filterableDecorator(ingredients)
    availableIngredients.filter((m) -> m.get('available'))

    headeredIngredients = ingredients.models.slice()
    lastLetter = ''
    i = 0
    while i < headeredIngredients.length
      letter = headeredIngredients[i].get('tag')[0].toLowerCase()
      if letter != lastLetter
        headeredIngredients.splice i, 0, new StickyHeaderList.HeaderModel { header : letter }
        lastLetter = letter
        i++
      i++

    headeredIngredients = new Backbone.Collection(headeredIngredients)

    return {
      app
      ingredients
      availableIngredients
      headeredIngredients
    }

  initializePersistence = (globals) ->
    new Persistence.Ingredients(ingredients : globals.ingredients).load()
    globals.availableIngredients.filter()

  initializeViews = (globals) ->
    globals.app.header.show new PageHeader
      collection : globals.ingredients
    globals.app.list.show new (class L extends StickyHeaderList.HeaderedLayout
      className : -> super + ' ingredient-list'
    ) {
      collection : globals.headeredIngredients
      itemView   : IngredientItemView
    }

  return ->
    globals = initializeGlobals()
    initializePersistence(globals)
    initializeViews(globals)

    globals.app.start()

    return globals
