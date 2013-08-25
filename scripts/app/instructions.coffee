define [ 'backbone'
         'marionette'
         'hbs!../templates/instructions'
         'less!../styles/instructions' ],
(Backbone, Marionette, instructions) ->
  class View extends Marionette.ItemView
    className: 'instructions'
    template: instructions

  class EmptyView extends Marionette.ItemView
    className: 'instructions empty'
    template: -> 'select a recipe on the left'

  return {
    View: View
    EmptyView: EmptyView
  }
