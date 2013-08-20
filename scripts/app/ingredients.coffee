define [ 'backbone'
         'marionette'
         'cs!./selectable-list'
         'cs!./drink'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-sidebar'
         'less!../styles/ingredients' ],
(Backbone, Marionette, SelectableList, Drink, ingredient_list_item, search_sidebar) ->
  class Model extends Backbone.Model
    defaults: ->
      name: ''
      selected: false
      implies: []

  class SearchModel extends Backbone.Model
    defaults:
      loading: false
      search: ''

  class IngredientItemView extends SelectableList.ItemView
    className: -> super + ' ingredient'
    template: ingredient_list_item

    renderSelected: ->
      super
      selected = @model.get('selected')
      @$('.icon').toggleClass('icon-check', selected)
      @$('.icon').toggleClass('icon-check-empty', not selected)

  class ResultItemView extends IngredientItemView
    className: -> super + ' search-result'

  class NoResultsView extends Marionette.ItemView
    className: 'empty-message'
    template: '<span>no results</span>'

  class NoSelectionView extends Marionette.ItemView
    className: 'empty-message'
    template: '<span>nothing selected</span>'

  class ListView extends Marionette.Layout
    className: 'ingredients-sidebar'
    template: search_sidebar

    regions:
      list: '.list-container'

    events:
      'input input.search-bar': '_filter'
      'keydown input.search-bar': '_inputKeydown'
      'keydown .list-container': '_listKeyDown'

    constructor: ({@search, @searchedCollection, @selectedCollection}) -> super

    onShow: ->
      @_showSelectedList()

    _filter: ->
      search = @$('.search-bar').val().trim()
      oldSearch = @search.get('search')
      @search.set 'search', search
      if search and not oldSearch
        @_showSearchedList()
      else if not search and oldSearch
        @_showSelectedList()

    _showSearchedList: ->
      @list.show new SelectableList.ListView
        # className: SelectableList.ListView::className + ' showing-searched'
        collection: @searchedCollection
        itemView: ResultItemView
        emptyView: NoResultsView
      @list.currentView.exitTop = @_selectInput

    _showSelectedList: ->
      @list.show new SelectableList.ListView
        # className: SelectableList.ListView::className + ' showing-selected'
        collection: @selectedCollection
        itemView: IngredientItemView
        emptyView: NoSelectionView
      @list.currentView.exitTop = @_selectInput

    _selectInput: =>
      $input = @$('input.search-bar')
      $input.focus().val($input.val()) # bump cursor to end

    _inputKeydown: (ev) ->
      if ev.which == 40 # down arrow
        ev.stopPropagation()
        @list.currentView.enterTop()

    _listKeyDown: (ev) ->
      if ev.which != 16 and ev.which != 17 and ev.which != 18 # shift, ctrl, alt
        @_selectInput()

  # todo: clean this code up a bit once the model fields have stabilized
  generateIngredientMatcher = (searchString) ->
    return (m) ->
      if m.get('name').indexOf(searchString) != -1
        return true
      return false

  return {
    Model: Model
    SearchModel: SearchModel
    ListView: ListView
    generateIngredientMatcher: generateIngredientMatcher
  }
