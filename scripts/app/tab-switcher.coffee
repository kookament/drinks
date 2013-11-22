define [
  'underscore'
  'marionette'
  'hbs!../templates/tab-switcher'
  'hbs!../templates/tab-pane'
  'less!../../styles/tabs'
], (
  _
  Marionette
  tabSwitcherTemplate
  tabPaneTemplate
) ->
  class TabSwitcherView extends Marionette.ItemView
    className : 'tab-switcher'
    template  : tabSwitcherTemplate

    events :
      'click .tab-option' : '_switch'

    modelEvents :
      'change:selected' : '_renderSelected'

    ui :
      $options : '.tab-option'

    onRender : ->
      @_renderSelected()

    _switch : (ev) ->
      key = $(ev.currentTarget).data('key')
      option = _.findWhere(@model.get('options'), { key })
      if option? and @model.get('selected')?.key != key
        @model.set 'selected', option

    _renderSelected : ->
      @ui.$options.removeClass('selected')
      key = @model.get('selected')?.key
      if key?
        @ui.$options.filter("[data-key=#{key}]").addClass('selected')

  class EmptyPaneView extends Marionette.ItemView
    template : -> '<div>empty</div>'

  class TabPaneView extends Marionette.Layout
    className : 'tab-pane'
    template  : tabPaneTemplate

    regions :
      switcher : '.tab-switcher'
      content  : '.tab-content'

    modelEvents :
      'change:selected' : '_renderSelected'

    onRender : ->
      @switcher.show new TabSwitcherView(model : @model)
      @content.show @model.get('selected')?.view ? new EmptyPaneView

    _renderSelected : ->
      @content.show @model.get('selected')?.view ? new EmptyPaneView

  return {
    TabSwitcherView
    TabPaneView
  }