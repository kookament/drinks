exports = window.list ?= {}

class exports.ListItemModel extends Backbone.Model
  defaults: ->
    text: ''

class exports.ListModel extends Backbone.Model
  defaults: ->
    items: new Backbone.Collection

  initialize: ->
    m = @get('model') ? exports.ListItemModel
    @get('items').model = m
    @unset 'model'

class exports.ListView extends Backbone.View
  className: 'list-view'

  initialize: ->
    @listenTo @model.get('items'), 'reset', @renderItems

  render: ->
    @rendered = true

  renderItems: ->
    return unless @rendered
    $l = $('<div/>')
    for i in @model.get('items').models
      $i = @generateItemElement(i)
      $l.append $i if $i
    @$el.empty().append $l.children()

  generateItemElement: (item) ->
    return $('<div class="list-item"/>').text item.get('text')

# options: itemClass, listClass, viewClass
exports.bundle = (options) ->
  options ?= {}
  model = new (options.listClass ? exports.ListModel)
    model: (options.itemClass ? exports.ListItemModel)
  view = new (options.viewClass ? exports.ListView)
    model: model
  return {
    model: model
    view: view
  }
