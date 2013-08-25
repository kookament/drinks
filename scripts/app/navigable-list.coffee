define [ 'backbone'
         'marionette'
         'less!../styles/navigable-list' ],
(Backbone, Marionette) ->
  # understand a click event to mean toggle the selection
  class ItemView extends Marionette.ItemView
    className: -> 'list-item'
    tagName: 'tr'

  # understands keyboard navigation, can enter/exit navigation from top or bottom
  # of list, and will set the 'selected' flag on any model that is highlighted when
  # Enter is pressed
  class ListView extends Marionette.CollectionView
    tagName: 'table'
    className: -> 'navigable-list'
    attributes:
      tabindex: 0

    events: ->
      'keydown': 'keydown'
      'click .list-item': 'click'

    enterTop: ->
      @activate 0

    enterBottom: ->
      @activate @collection.length - 1

    activate: (i) ->
      @$el.focus()
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      @$('.list-item').eq(i).addClass('active').trigger('navigate-active')
      @trigger 'activate', i

    deselect: ->
      @$el.blur()
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      @trigger 'deselect'

    exitTop: -> # default no-op

    exitBottom: -> # default no-op

    _keyhandlers:
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

    _up: (ev) ->
      $items = @$('.list-item')
      i = $items.filter('.active').index()
      if i > -1
        if i > 0
          @activate i - 1
        else
          @exitTop()

    _down: (ev) ->
      $items = @$('.list-item')
      i = $items.filter('.active').index()
      if i > -1
        if i < $items.length - 1
          @activate i + 1
        else
          @exitBottom()

    click: (ev) ->
      @activate $(ev.currentTarget).index()

  return {
    ItemView: ItemView
    ListView: ListView
  }
