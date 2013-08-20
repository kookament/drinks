define [ 'backbone'
         'marionette'
         'less!../styles/navigable-list' ],
(Backbone, Marionette) ->
  # understand a click event to mean toggle the selection
  class ItemView extends Marionette.ItemView
    className: -> 'list-item'
    tagName: 'tr'
    attributes:
      tabindex: '0'

  # understands keyboard navigation, can enter/exit navigation from top or bottom
  # of list, and will set the 'selected' flag on any model that is highlighted when
  # Enter is pressed
  class ListView extends Marionette.CollectionView
    tagName: 'table'
    className: -> 'navigable-list'

    events: ->
      'keydown tr': 'keydown'

    enterTop: ->
      @$('.list-item:first-child').focus()

    enterBottom: ->
      @$('.list-item:last-child').focus()

    exitTop: -> # default no-op

    exitBottom: -> # default no-op

    _keyhandlers:
      '9': '_tab'
      '37': 'left'
      '38': '_up'
      '39': 'right'
      '40': '_down'

    keydown: (ev) ->
      fn = this[@_keyhandlers[ev.which]]
      if fn
        ev.stopPropagation()
        fn.apply this, arguments

    left: -> # nop

    right: -> # nop

    _tab: (ev) -> # nop

    _up: (ev) ->
      $items = @$('.list-item')
      i = $items.filter(':focus').index()
      if i > -1
        if i > 0
          $items.eq(i - 1).focus()
        else
          @exitTop()

    _down: (ev) ->
      $items = @$('.list-item')
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
