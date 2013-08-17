define [ 'backbone' ],
(Backbone) ->
  # translated from http://jsfiddle.net/derickbailey/7tvzF/
  filterableDecorator: (collection) ->
    # whoa.
    filtered = new collection.constructor

    filtered.where = (criteria) ->
      filtered._criteria = criteria
      if criteria
        filtered.reset collection.where(criteria)
      else
        filtered.reset collection.models

    # this is real inefficient
    filtered.listenTo collection, 'add remove reset', ->
      filtered.where(filtered._criteria)

  return {
    filterableDecorator: filterableDecorator
  }
