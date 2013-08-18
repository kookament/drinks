define [ 'backbone' ],
(Backbone) ->
  # translated from http://jsfiddle.net/derickbailey/7tvzF/
  filterableDecorator = (collection) ->
    # whoa.
    filtered = new collection.constructor

    filtered.filter = (fn) ->
      filtered._fn = fn
      if fn
        filtered.reset collection.filter(fn)
      else
        filtered.reset collection.models

    # this is real inefficient
    filtered.listenTo collection, 'add remove reset', ->
      filtered.where(filtered._fn)

  return filterableDecorator
