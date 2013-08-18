define [ 'backbone'
         'marionette'
         'cs!./drink'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-bar'
         'less!../styles/ingredients' ],
(Backbone, Marionette, Drink, ingredient_list_item, search_bar) ->
  class Model extends Backbone.Model
    defaults:
      name: ''
      selected: false
      implies: []

  class SearchResult extends Marionette.ItemView
    className: 'ingredient-list-item'
    template: ingredient_list_item
    attributes:
      tabindex: '0'

    events:
      'click': '_click'
      'mousedown': '_mousedown'

    modelEvents:
      'change:selected': '_renderSelected'

    _click: (ev) ->
      @model.set 'selected', not @model.get('selected')

    _mousedown: (ev) ->
      # prevent focus-on-click because this has a tabindex
      ev.preventDefault()

    _renderSelected: ->
      @$el.toggleClass 'selected', @model.get('selected')

    render: ->
      super
      @_renderSelected()

  class SearchModel extends Backbone.Model
    defaults:
      loading: false
      search: ''

  class Sidebar extends Marionette.CompositeView
    className: 'search-sidebar'
    template: search_bar
    itemView: SearchResult
    itemViewContainer: '.ingredient-results'

    events:
      'input input.search-bar': '_filter'
      'keydown input.search-bar': '_inputKeydown'
      'keydown .ingredient-list-item': '_listKeydown'

    keyhandlers:
      '9': '_tab'
      '13': '_enter'
      '38': '_up'
      '40': '_down'

    constructor: ({@search}) -> super

    _filter: ->
      @search.set 'search', @$('.search-bar').val()

    _inputKeydown: (ev) ->
      if ev.which == 40 # down arrow
        ev.stopPropagation()
        $first = @$itemViewContainer.children().eq(0)
        if $first.length
          $first.focus()

    _listKeydown: (ev) ->
      fn = this[@keyhandlers[ev.which]]
      if fn
        ev.stopPropagation()
        fn.apply this, arguments
      else if ev.which != 16 and ev.which != 17 and ev.which != 18 # shift, cttl, alt
        @$('input.search-bar').focus()

    _tab: (ev) -> # nop

    _enter: (ev) ->
      i = @$itemViewContainer.children().filter(':focus').index()
      if i > -1 and i < @collection.length
        m = @collection.at(i)
        m.set 'selected', not m.get('selected')

    _up: (ev) ->
      $children = @$itemViewContainer.children()
      i = $children.filter(':focus').index()
      if i == 0
        @$('input.search-bar').focus()
      else if i > -1 and i > 0
        $children.eq(i - 1).focus()

    _down: (ev) ->
      $children = @$itemViewContainer.children()
      i = $children.filter(':focus').index()
      if i > -1 and i < $children.length - 1
        $children.eq(i + 1).focus()

  # todo: clean this code up a bit once the model fields have stabilized
  generateIngredientMatcher = (searchString) ->
    return (m) ->
      if m.get('name').indexOf(searchString) != -1
        return true
      return false

  return {
    Model: Model
    SearchModel: SearchModel
    SearchResult: SearchResult
    Sidebar: Sidebar
    generateIngredientMatcher: generateIngredientMatcher
  }
