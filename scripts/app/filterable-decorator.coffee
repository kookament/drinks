define [ 'backbone' ],
(Backbone) ->
  # translated from http://jsfiddle.net/derickbailey/7tvzF/
  filterableDecorator = (collection) ->
    # whoa.
    filtered = new collection.constructor

    filtered._fn = -> true

    filtered.filter = (fn) ->
      if fn
        filtered._fn = fn
      filtered.reset collection.filter(filtered._fn)

    filtered.filter()

    # this is real inefficient
    filtered.listenTo collection, 'add remove reset', ->
      filtered.where(filtered._fn)

    return filtered

  return filterableDecorator
