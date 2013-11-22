define [ 'underscore'
         'backbone'
         'marionette'
         'cs!./selectable-list'
         'json!../data/synonyms.json'
         'hbs!../templates/ingredient-list-item'
         'hbs!../templates/search-box'
         'hbs!../templates/search-sidebar'
         'backbone.mutators'
         'less!../../styles/ingredients' ],
(_
 Backbone
 Marionette
 SelectableList
 synonyms
 ingredient_list_item
 search_box
 search_sidebar) ->
  class Model extends Backbone.Model
    defaults: ->
      tag: ''
      selected: false
      implied: false

    mutators:
      available: -> @get('selected') or @get('implied')

  class MatchModel extends Model
    defaults: ->
      _.extend super, {
        synonym: false
        prefix: ''
        match: ''
        suffix: ''
      }

  class SearchModel extends Backbone.Model
    defaults:
      search: ''

  class ResultItemView extends SelectableList.ItemView
    className: -> super + ' ingredient'
    template: ingredient_list_item

    modelEvents: ->
      _.extend super, {
        'change:selected': 'renderAvailability' # override
        'change:implied': 'renderAvailability'
      }

    onRender: ->
      super
      @renderAvailability()

    renderAvailability: ->
      @renderSelected()
      @$el.toggleClass 'implied', @model.get('implied')
      available = @model.get 'available'
      @$('.list-icon').toggleClass('icon-check', available)
      @$('.list-icon').toggleClass('icon-check-empty', not available)

  class NoResultsView extends SelectableList.EmptyView
    template: -> '<td>no results</td>'

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
      @list.ensureEl() # this is because we want to pull out @list.$el below and is gross
      list = new (class L extends SelectableList.ListView
        collection: that.collection
        itemView: ResultItemView
        emptyView: NoResultsView

        exitTop: ->
          @deselect()
          that.search.currentView.focusInput()

        exitBottom: ->
          @deselect()
          that.search.currentView.focusInput()

        left: that.options.leftArrowKey
        right: that.options.rightArrowKey
      ) { $scrollContainer: @list.$el }
      @list.show list

    _inputKeydown: (ev) ->
      if @collection.length
        if ev.which == 40 # down arrow
          ev.stopPropagation()
          ev.preventDefault()
          @list.currentView.enterTop()
        else if ev.which == 38 # up arrow
          ev.stopPropagation()
          ev.preventDefault()
          @list.currentView.enterBottom()

    _listKeyDown: (ev) ->
      if ev.which != 16 and ev.which != 17 and ev.which != 18 and ev.which != 91 # shift, ctrl, alt, cmd
        @search.currentView.$('input').val('')
        @search.currentView.focusInput()

  generateIngredientMatcher = (searchString) ->
    if not searchString
      return (m) ->
        return {
          synonym: false
          prefix: m.get('tag')
          match: ''
          suffix: ''
        }
    else
      searchString = searchString.toLowerCase()
      return (m) ->
        tag = m.get('tag')
        i = tag.indexOf(searchString)
        if i != -1
          return {
            synonym: false
            prefix: tag.slice(0, i)
            match: tag.slice(i, i + searchString.length)
            suffix: tag.slice(i + searchString.length)
          }
        for s in synonyms[tag] ? []
          i = s.indexOf(searchString)
          if i != -1
            return {
              synonym: true
              prefix: s.slice(0, i)
              match: s.slice(i, i + searchString.length)
              suffix: s.slice(i + searchString.length)
            }
        return false

  return {
    Model: Model
    MatchModel: MatchModel
    SearchModel: SearchModel
    SearchSidebar: SearchSidebar
    generateIngredientMatcher: generateIngredientMatcher
  }
