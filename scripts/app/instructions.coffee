define [ 'backbone'
         'marionette'
         'hbs!../templates/instructions'
         'less!../../styles/instructions' ],
(Backbone
 Marionette
 instructions) ->
  class View extends Marionette.ItemView
    className: 'instructions-container'
    template: instructions

    constructor: ({@available}) -> super

    onRender: ->
      @$('.ingredient[data-tag]').each (i, el) =>
        $el = $(el)
        if $el.data('tag') and not @available.findWhere(tag: $el.data('tag'))
          $el.addClass 'unavailable'

  class EmptyView extends Marionette.ItemView
    className: 'instructions-container empty'
    template: -> 'select a recipe on the left'

  return {
    View: View
    EmptyView: EmptyView
  }
