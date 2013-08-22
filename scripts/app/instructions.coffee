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
    template: '<span>nothing selected</span>'

  return {
    View: View
    EmptyView: EmptyView
  }
