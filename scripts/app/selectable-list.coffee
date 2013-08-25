define [ 'underscore'
         'backbone'
         'cs!./navigable-list'
         'less!../styles/selectable-list' ],
(_, Backbone, NavigableList) ->
  # understand a click event to mean toggle the selection
  class ItemView extends NavigableList.ItemView
    className: -> super + ' selectable'

    events:
      'click': '_click'

    modelEvents:
      'change:selected': 'renderSelected'

    onShow: ->
      @renderSelected()

    _click: (ev) ->
      @model.set 'selected', not @model.get('selected')

    renderSelected: ->
      @$el.toggleClass 'selected', @model.get('selected')

  # understands keyboard navigation, can enter/exit navigation from top or bottom
  # of list, and will set the 'selected' flag on any model that is highlighted when
  # Enter is pressed
  class ListView extends NavigableList.ListView
    className: -> super + ' selectable'

    keydown: (ev) ->
      if ev.which == 13 # enter
        ev.stopPropagation()
        i = @$('.list-item.active').index()
        if i > -1 and i < @collection.length
          m = @collection.at(i)
          m.set 'selected', not m.get('selected')
      else
        super

  return {
    ItemView: ItemView
    EmptyView: NavigableList.EmptyView
    ListView: ListView
  }
