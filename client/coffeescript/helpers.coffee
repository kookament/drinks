Handlebars.registerHelper 'ingredient', (context) ->
  ingredient = ''
  for piece in context
    if _.isString piece
      ingredient += piece
    else if _.isObject piece
      if piece.quantity
        ingredient += "<span class='quantity'>#{piece.quantity}</span>"
      else if piece.unit
        ingredient += "<span class='unit'>#{piece.unit}</span>"
    else
      console.error "Unrecognized ingredient piece: #{piece}."
  return ingredient

Handlebars.registerHelper 'gt', (l, r, options) ->
  if l > r
    options.fn this
  else
    options.inverse this
