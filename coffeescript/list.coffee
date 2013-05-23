list = window.list ?= {}

class list.ListItemModel extends Backbone.Model
  defaults: ->
    text: ''

class list.ListModel extends Backbone.Model
  defaults: ->
    # loading: false
    items: new Backbone.Collection

  initialize: ->
    m = @get('model') ? list.ListItemModel
    @get('items').model = m
    @unset 'model'

class list.ListView extends Backbone.View
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
list.bundle = (options) ->
  options ?= {}
  model = new (options.listClass ? list.ListModel)
    model: (options.itemClass ? list.ListItemModel)
  view = new (options.viewClass ? list.ListView)
    model: model
  return {
    model: model
    view: view
  }
