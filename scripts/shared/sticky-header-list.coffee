define [
  'underscore'
  'backbone'
  'marionette'
  'cs!./list'
  'less!../../styles/sticky-header-list'
], (
  _
  Backbone
  Marionette
  List
) ->
  class HeaderedLayout extends Marionette.Layout
    className : -> 'sticky-headered-layout'
    template : -> '<div class="sticky-header"></div><div class="list-container"></div>'

    regions :
      header : '.sticky-header'
      list   : '.list-container'

    onShow : ->
      @listenTo @collection, 'change:first', @_onChangeFirst

      @_listView = new (@options.listView ? ListView)(@options)
      @list.show @_listView

    _onChangeFirst : (m, first) ->
      if first
        @header.show new (@_listView.getItemView(m))(model : m)

  class ListView extends List.ListView
    getItemView : (m) ->
      if m instanceof HeaderModel
        return @options.headerView ? HeaderView
      else
        return @options.itemView ? List.ListItemView

    onShow : ->
      # Can't delegate scroll (i.e. doesn't work in the events hash).
      @$el.scroll _.throttle(@_onScroll, 100)
      @_firstHeaderModel = @collection.find((m) -> m instanceof HeaderModel)
      @_firstHeaderModel?.set 'first', true

    _onScroll : =>
      headerModels = @collection.filter((m) -> m instanceof HeaderModel)
      newFirst = _.chain(headerModels)
        .map((m) => { model : m, offset : @children.findByModel(m).$el.offset().top })
        .find((v, i, a) -> i < a.length - 1 and v.offset < 0 and  a[i + 1].offset >= 0)
        .value()?.model ? headerModels[0]
      if newFirst != @_firstHeaderModel
        @_firstHeaderModel?.unset 'first'
        @_firstHeaderModel = newFirst
        @_firstHeaderModel?.set 'first', true

  class HeaderView extends Marionette.ItemView
    className : -> 'header-item'
    template : (m) -> m.header

  class HeaderModel extends Backbone.Model
    defaults :
      header : 'header'

  return {
    HeaderedLayout
    ListView
    HeaderView
    HeaderModel
  }