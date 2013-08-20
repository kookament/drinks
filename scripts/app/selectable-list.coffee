define [ 'backbone'
         'marionette'
         'less!../styles/selectable-list' ],
(Backbone, Marionette) ->
  # understand a click event to mean toggle the selection
  class ItemView extends Marionette.ItemView
    className: -> 'selectable-list-item'
    tagName: 'tr'
    attributes:
      tabindex: '0'

    events:
      'click': '_click'
      'mousedown': '_mousedown'

    modelEvents:
      'change:selected': 'renderSelected'

    onShow: ->
      @renderSelected()

    _click: (ev) ->
      @model.set 'selected', not @model.get('selected')

    _mousedown: (ev) ->
      # prevent focus-on-click because this has a tabindex
      ev.preventDefault()

    renderSelected: ->
      @$el.toggleClass 'selected', @model.get('selected')

  # understands keyboard navigation, can enter/exit navigation from top or bottom
  # of list, and will set the 'selected' flag on any model that is highlighted when
  # Enter is pressed
  class ListView extends Marionette.CollectionView
    tagName: 'table'
    className: 'selectable-list'

    events: ->
      'keydown tr': '_keydown'

    enterTop: ->
      @$('.selectable-list-item:first-child').focus()

    enterBottom: ->
      @$('.selectable-list-item:last-child').focus()

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
      i = @$('.selectable-list-item').filter(':focus').index()
      if i > -1 and i < @collection.length
        m = @collection.at(i)
        m.set 'selected', not m.get('selected')

    _up: (ev) ->
      $items = @$('.selectable-list-item')
      i = $items.filter(':focus').index()
      if i > -1
        if i > 0
          $items.eq(i - 1).focus()
        else
          @exitTop()

    _down: (ev) ->
      $items = @$('.selectable-list-item')
      i = $items.filter(':focus').index()
      if i > -1
        if i < $items.length - 1
          $items.eq(i + 1).focus()
        else
          @exitBottom()

  return {
    ItemView: ItemView
    ListView: ListView
  }
