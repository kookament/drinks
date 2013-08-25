define [ 'backbone'
         'marionette'
         'cs!./selectable-list'
         'cs!./drink'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-box'
         'hbs!../templates/search-sidebar'
         'less!../styles/ingredients' ],
(Backbone, Marionette, SelectableList, Drink, ingredient_list_item, search_box, search_sidebar) ->
  class Model extends Backbone.Model
    defaults: ->
      name: ''
      selected: false
      implies: []

  class SearchModel extends Backbone.Model
    defaults:
      loading: false
      search: ''

  class ResultItemView extends SelectableList.ItemView
    className: -> super + ' ingredient'
    template: ingredient_list_item

    renderSelected: ->
      super
      selected = @model.get('selected')
      @$('.list-icon').toggleClass('icon-check', selected)
      @$('.list-icon').toggleClass('icon-check-empty', not selected)

  class NoResultsView extends Marionette.ItemView
    className: 'empty-message'
    template: '<span>no results</span>'

  class SearchBarView extends Marionette.ItemView
    className: 'search-bar'
    template: search_box

    events:
      'input input.search-input': '_filter'

    _filter: ->
      @model.set 'search', @$('input.search-input').val().trim()

    focusInput: =>
      $input = @$('input.search-input')
      $input.focus().val($input.val()) # bump cursor to end

  class SearchSidebar extends Marionette.Layout
    className: 'ingredients-sidebar'
    template: search_sidebar

    options:
      leftArrowKey: ->
      rightArrowKey: ->

    regions:
      search: '.search-container'
      list: '.list-container'

    events:
      'keydown .search-container input': '_inputKeydown'
      'keydown .list-container': '_listKeyDown'

    onShow: ->
      @search.show new SearchBarView
        model: @model
      that = this
      list = new (class L extends SelectableList.ListView
        # className: SelectableList.ListView::className + ' showing-searched'
        collection: that.collection
        itemView: ResultItemView
        emptyView: NoResultsView

        exitTop: ->
          @deselect()
          that.search.currentView.focusInput()

        left: that.options.leftArrowKey
        right: that.options.rightArrowKey
      )
      @list.show list

    _inputKeydown: (ev) ->
      if ev.which == 40 # down arrow
        ev.stopPropagation()
        @list.currentView.enterTop()

    _listKeyDown: (ev) ->
      if ev.which != 16 and ev.which != 17 and ev.which != 18 # shift, ctrl, alt
        @search.currentView.focusInput()

  # todo: clean this code up a bit once the model fields have stabilized
  generateIngredientMatcher = (searchString) ->
    if not searchString
      return -> return true
    else
      return (m) ->
        if m.get('name').indexOf(searchString) != -1
          return true
        return false

  return {
    Model: Model
    SearchModel: SearchModel
    SearchSidebar: SearchSidebar
    generateIngredientMatcher: generateIngredientMatcher
  }
