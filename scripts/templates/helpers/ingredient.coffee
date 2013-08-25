define [ 'handlebars' ],
(Handlebars) ->
  _QUANTITY_RE = /\{[qQ]([^}]*)\}/
  _UNIT_RE = /\{[uU]([^}]*)\}/

  format = (ingredient) ->
    text = Handlebars.Utils.escapeExpression ingredient.instruction
    text = text.replace _QUANTITY_RE, '<span class="quantity">$1</span>'
    text = text.replace _UNIT_RE, '<span class="unit">$1</span>'

    name = Handlebars.Utils.escapeExpression ingredient.name

    return new Handlebars.SafeString "<li class='ingredient' data-name='#{name}'>#{text}</li>"

  Handlebars.registerHelper 'ingredient', format
  return {}
