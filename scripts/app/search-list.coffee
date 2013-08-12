define [ 'backbone'
         'marionette'
         'cs!./drink'
         'hbs!../templates/drink-list-item' ],
(Backbone, Marionette, Drink, drink_list_item) ->
  class DrinkListItem extends Marionette.ItemView
    template: drink_list_item

  class ResultCollection extends Backbone.Collection
    model: Drink
    comparator: 'name'

  class ResultListView extends Marionette.CollectionView
