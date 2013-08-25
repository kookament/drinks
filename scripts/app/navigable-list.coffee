define [ 'marionette'
         'less!../styles/navigable-list' ],
(Marionette) ->
  # understand a click event to mean toggle the selection
  class ItemView extends Marionette.ItemView
    tagName: 'tr'
    className: -> 'list-item'

  class EmptyView extends Marionette.ItemView
    tagName: 'tr'
    className: -> 'empty-message'

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
      'focus': 'focus'
      'blur': 'blur'

    grabFocus: (ev = null) ->
      # this is gross, but I want it to enterTop when we get focused...
      if ev?.type != 'focus' and ev?.type != 'blur'
        @$el.focus()

    isActive: ->
      return !!@$('.list-item.active').length

    enterTop: (ev = null) ->
      if not @isActive()
        @activate 0, ev
      else
        @grabFocus(ev)

    enterBottom: (ev = null) ->
      if not @isActive()
        @activate @collection.length - 1
      else
        @grabFocus(ev)

    activate: (i, ev = null) ->
      @grabFocus(ev)
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      @$('.list-item').eq(i).addClass('active').trigger('navigate-active')
      @trigger 'activate', i

    deselect: ->
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      @trigger 'deselect'

    exitTop: ->
      @enterBottom()

    exitBottom: ->
      @enterTop()

    focus: (ev) ->
      @enterTop(ev)

    blur: (ev) ->
      @deselect(ev)

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

    _tab: -> # nop; swallow this event

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
    EmptyView: EmptyView
    ListView: ListView
  }
