define [ 'backbone'
         'marionette'
         'cs!./drink'
         'hbs!../templates/drink-list-item' ],
(Backbone, Marionette, Drink, drink_list_item) ->
  # This is not a great system:
  # 1. we're adding an undocumented field to our models
  # 2. this field only works when we have a view like this understands it
  # 3. single-selection can only be enforced when the model is in a collection, as below
  # 4. what should be a single piece of state is split between every model + the collection's enforcement policy
  # 5. gets/sets are expensive (traverse all models, unset flags, fire lots of change events)
  # on the flipside:
  # 1. the view can be dumb and only render fields that exist on the model (doesn't need to know about container)
  class DrinkListItem extends Marionette.ItemView
    className: 'drink-list-item'
    template: drink_list_item

    events:
      'click': '_select'

    modelEvents:
      'change:selected': '_renderSelected'

    _select: ->
      @model.set selected: true

    _renderSelected: ->
      @$el.toggleClass 'selected', @model.get('selected')

  class ResultCollection extends Backbone.Collection
    model: Drink
    comparator: 'name'

    initialize: ->
      @listenTo this, 'change:selected', @_enforceSingleSelected

    _enforceSingleSelected: (m) ->
      if m.get('selected')
        _.chain(@models).without(m).each((m) -> m.set selected: false)

  class ResultListView extends Marionette.CollectionView
    itemView: DrinkListItem

  return {
    DrinkListItem: DrinkListItem
    ResultCollection: ResultCollection
    ResultListView: ResultListView
  }
