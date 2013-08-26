define [ 'handlebars' ],
(Handlebars) ->
  _QUANTITY_RE = /\{[qQ]([^}]*)\}/
  _UNIT_RE = /\{[uU]([^}]*)\}/

  format = (ingredient) ->
    text = Handlebars.Utils.escapeExpression ingredient.display
    text = text.replace _QUANTITY_RE, '<span class="quantity">$1</span>'
    text = text.replace _UNIT_RE, '<span class="unit">$1</span>'

    tag = Handlebars.Utils.escapeExpression ingredient.tag

    return new Handlebars.SafeString "<li class='ingredient' data-tag='#{tag}'>#{text}</li>"

  Handlebars.registerHelper 'ingredient', format
  return {}
