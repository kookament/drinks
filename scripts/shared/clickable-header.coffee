define [
  'marionette'
  'less!../../styles/m/clickable-header'
], (
  Marionette
) ->
  class View extends Marionette.ItemView
    className : -> 'clickable-header'
    template  : -> '<div class="left"></div><div class="right"></div>'

    ui :
      $left  : '.left'
      $right : '.right'

    events :
      'click' : 'onClick'

    onClick : ->

  return {
    View
  }