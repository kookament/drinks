define [ 'backbone'
         'marionette'
         'less!../styles/selectable-list' ],
(Backbone, Marionette) ->
  # understand a click event to mean toggle the selection
  class ItemView extends Marionette.ItemView
    tagName: 'li'
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

  # understands keyboard navigation, can enter/exit navigation from top or bottom
  # of list, and will set the 'selected' flag on any model that is highlighted when
  # Enter is pressed
  class ListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'selectable-list'

    events: ->
      'keydown li': '_keydown'

    enterTop: ->
      @$el.children().first().focus()

    enterBottom: ->
      @$el.children().last().focus()

    exitTop: -> # default no-op

    exitBottom: -> # default no-op

    _keyhandlers:
      '9': '_tab'
      '13': '_enter'
      '38': '_up'
      '40': '_down'

    _keydown: (ev) ->
      fn = this[@_keyhandlers[ev.which]]
      if fn
        ev.stopPropagation()
        fn.apply this, arguments

    _tab: (ev) -> # nop

    _enter: (ev) ->
      i = @$el.children().filter(':focus').index()
      if i > -1 and i < @collection.length
        m = @collection.at(i)
        m.set 'selected', not m.get('selected')

    _up: (ev) ->
      $children = @$el.children()
      i = $children.filter(':focus').index()
      if i > -1
        if i > 0
          $children.eq(i - 1).focus()
        else
          @exitTop()

    _down: (ev) ->
      $children = @$el.children()
      i = $children.filter(':focus').index()
      if i > -1
        if i < $children.length - 1
          $children.eq(i + 1).focus()
        else
          @exitBottom()

  return {
    ItemView: ItemView
    ListView: ListView
  }
