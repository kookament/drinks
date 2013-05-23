search = window.search ?= {}

class search.TagsModel extends Backbone.Model
  defaults: ->
    universe: []
    current: []

class search.SearchBarView extends Backbone.View
  className: 'search-bar'

  events:
    'click input[type="submit"]': '_search'

  initialize: ->
    @tagsModel = @options.tagsModel
    @listenTo @tagsModel, 'change:universe', @_updateUniverse

  render: ->
    @rendered = true
    @$el.html Handlebars.templates.search()
    @$search = @$ 'input[type="hidden"]'
    @$search.width 400
    @_updateUniverse()

  _updateUniverse: ->
    @$search.select2
      placeholder: 'enter some tags'
      tags: @tagsModel.get('universe')
      createSearchChoice: -> # Prevent user from creating novel tags.
      openOnEnter: false

  _search: ->
    @tagsModel.set 'current', @$search.select2('val')

class search.SearchController
  constructor: (options) ->
    _.extend @, options, Backbone.Events

    @listenTo @tagsModel, 'change:current', @_search

  _search: ->
    window.api.forTags @tagsModel.get('current'), @_success, @_fail

  _success: (data) =>
    # Results is assumed to be a ListModel.
    @resultsModel.get('items').reset _.map data, (d) -> _.defaults { text : d.name }, d

  _fail: =>
    console.error arguments

# options: required: resultsModel
search.bundle = (options) ->
  options ?= {}
  tagsModel = new search.TagsModel
  view = new search.SearchBarView
    tagsModel: tagsModel
  controller = new search.SearchController
    tagsModel: tagsModel
    resultsModel: options.resultsModel

  return {
    tagsModel: tagsModel
    view: view
    controller: controller
  }
