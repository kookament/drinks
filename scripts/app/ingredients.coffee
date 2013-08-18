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
      aliases: []

  class SearchResult extends Marionette.ItemView
    className: 'ingredient-list-item'
    template: ingredient_list_item
    attributes:
      tabindex: '0'

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
      '38': '_up'
      '40': '_down'

    constructor: ({@search}) -> super

    _filter: ->
      @search.set 'search', @$('.search-bar').val()

    _inputKeydown: (ev) ->
      if ev.which == 40 # down arrow
        $first = @$itemViewContainer.children().eq(0)
        if $first.length
          $first.focus()

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

    _listKeydown: (ev) ->
      fn = this[@keyhandlers[ev.which]]
      if fn
        ev.stopPropagation()
        fn.apply this, arguments
      else
        console.log ev.which

  # todo: clean this code up a bit once the model fields have stabilized
  generateIngredientMatcher = (searchString) ->
    return (m) ->
      if m.get('name').indexOf(searchString) != -1
        return true
      else
        for a in m.get('aliases')
          if a.indexOf(searchString) != -1
            return true
        return false

  return {
    Model: Model
    SearchModel: SearchModel
    SearchResult: SearchResult
    Sidebar: Sidebar
    generateIngredientMatcher: generateIngredientMatcher
  }
