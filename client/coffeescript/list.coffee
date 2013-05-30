exports = window.list ?= {}

class exports.ListModel extends Backbone.Model
  defaults: ->
    items: new Backbone.Collection
    # Can't be another backbone collection, else the cid changes between items and selected. :(
    selected: []

  initialize: ->
    m = @get('model') ? exports.ListItemModel
    @get('items').model = m
    @unset 'model'

class exports.ListView extends Backbone.View
  className: 'list-view'

  events:
    'click .list-item': '_onClick'

  initialize: ->
    @listenTo @model.get('items'), 'reset', @renderItems
    @listenTo @model, 'change:selected', @renderSelection

  render: ->
    @rendered = true

  renderItems: ->
    return unless @rendered
    $l = $('<div/>')
    if @model.get('items').length
      for m in @model.get('items').models
        $item = @generateItemElement m
        $l.append $item if $item
      $l.append Handlebars.templates['no-more-list-items']()
    else
      $l.append Handlebars.templates['empty-list-placeholder']()
    @$el.empty().append $l.children()

  renderSelection: ->
    return unless @rendered
    @$('.list-item').removeClass 'selected'
    for m in @model.get 'selected'
      @elementForModel(m)?.addClass 'selected'
    return undefined

  elementForModel: (m) ->
    return @$(".list-item[data-cid='#{m.cid}']")

  modelForElement: ($e) ->
    return _.find @model.get('items').models, (m) -> m.cid == $e.data('cid')

  generateItemElement: (m) ->
    return $('<div class="list-item"/>').attr('data-cid', m.cid)

  _onClick: (ev) ->
    # TODO: This event is delegated, but can't we get the element that matched the selector off of the event?
    m = @modelForElement $(ev.target).closest('.list-item')
    @clickItem m, ev

  clickItem: (m, ev) ->
    if m
      @model.set 'selected', [m]
    else
      @model.set 'selected', []

# options: itemClass (req), listClass, viewClass
exports.bundle = (options) ->
  options ?= {}
  model = new (options.listClass ? exports.ListModel)
    model: options.itemClass
  view = new (options.viewClass ? exports.ListView)
    model: model
  return {
    model: model
    view: view
  }
