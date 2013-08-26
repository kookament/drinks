define [ 'marionette'
         'less!../styles/navigable-list' ],
(Marionette) ->
  class HeaderModel extends Backbone.Model
    defaults:
      text: ''

  class ItemView extends Marionette.ItemView
    tagName: 'tr'
    className: -> 'list-item'

  class HeaderView extends Marionette.ItemView
    tagName: 'tr'
    className: -> 'list-header'
    template: (attr) -> "<td class='header-text'>#{attr.text}</td>"

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

    options:
      $scrollContainer: null # pass this to automatically scroll the elements into view if they aren't

    events: ->
      'keydown': 'keydown'
      'click .list-item': 'click'
      'focus': 'focus'
      'blur': 'blur'

    getItemView: (item) ->
      if item instanceof HeaderModel
        return HeaderView
      else
        return super

    grabFocus: (ev = null) ->
      # this is gross, but I want it to enterTop when we get focused...
      if ev?.type != 'focus' and ev?.type != 'blur'
        @$el.focus()

    isActive: ->
      return !!@$('.list-item.active').length

    enter: (ev = null) ->
      if not @isActive()
        @enterTop()
      else
        @grabFocus(ev)

    enterTop: (ev = null) ->
      @activate 0, ev

    enterBottom: (ev = null) ->
      @activate @collection.reject((i) -> i instanceof HeaderModel).length - 1

    activate: (i, ev = null) ->
      @grabFocus(ev)
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      $active = @$('.list-item').eq(i).addClass('active').trigger('navigate-active')
      if @options.$scrollContainer
        offset = $active.offset().top - @$el.offset().top
        scrollTop = @options.$scrollContainer.scrollTop()
        if offset < scrollTop
          $active[0].scrollIntoView(true)
        else if offset + $active.height() > @options.$scrollContainer.height() + scrollTop
          $active[0].scrollIntoView(false)
      @trigger 'activate', i

    deselect: ->
      @$('.list-item.active').removeClass('active').trigger('navigate-inactive')
      @trigger 'deselect'

    exitTop: ->
      @deselect()
      @enterBottom()

    exitBottom: ->
      @deselect()
      @enterTop()

    focus: (ev) ->
      if ev?.type != 'focus' and ev?.type != 'blur'
        @enterTop(ev)

    blur: (ev) ->
      if ev?.type != 'focus' and ev?.type != 'blur'
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
        ev.preventDefault()
        fn.apply this, arguments

    _tab: -> # nop; swallow this event

    left: -> # nop

    right: -> # nop

    _up: (ev) ->
      $items = @$('.list-item')
      i = $items.index $items.filter('.active')
      if i > -1
        if i > 0
          @activate i - 1
        else
          @exitTop()

    _down: (ev) ->
      $items = @$('.list-item')
      i = $items.index $items.filter('.active')
      if i > -1
        if i < $items.length - 1
          @activate i + 1
        else
          @exitBottom()

    click: (ev) ->
      @activate @$('.list-item').index $(ev.currentTarget)

  return {
    HeaderModel: HeaderModel
    ItemView: ItemView
    EmptyView: EmptyView
    ListView: ListView
  }
