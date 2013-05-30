exports = window.search ?= {}

class exports.TagsModel extends Backbone.Model
  defaults: ->
    universe: []
    current: []

class exports.SearchBarView extends Backbone.View
  className: 'search-bar'

  initialize: ->
    @tagsModel = @options.tagsModel
    @listenTo @tagsModel, 'change:universe', @_updateUniverse

  render: ->
    @rendered = true
    @$el.html Handlebars.templates['search']()
    @$search = @$ 'input[type="hidden"]'
    @$search.on 'change', @_search
    @_updateUniverse()

  _updateUniverse: ->
    @$search.select2
      width: '100%'
      placeholder: 'enter some tags'
      tags: @tagsModel.get('universe')
      createSearchChoice: -> # Prevent user from creating novel tags.
      openOnEnter: false
      minimumInputLength: 1
      formatInputTooShort: false

  _search: =>
    @tagsModel.set 'current', @$search.select2('val')

class exports.SearchController
  constructor: (options) ->
    _.extend @, options, Backbone.Events

    @listenTo @tagsModel, 'change:current', @_search

  _search: ->
    window.api.forTags @tagsModel.get('current'), @_success, @_fail

  _success: (data) =>
    # Results is assumed to be a ListModel.
    drinks = []
    _.each [0..1], (i) ->
      drinks = drinks.concat _.map(data[i], (d) -> _.defaults { text : d.name, missing: i }, d)
    @resultsModel.get('items').reset drinks
    console.log @resultsModel.get('items')

  _fail: =>
    console.error arguments

# options: required: resultsModel
exports.bundle = (options) ->
  options ?= {}
  tagsModel = new exports.TagsModel
  view = new exports.SearchBarView
    tagsModel: tagsModel
  controller = new exports.SearchController
    tagsModel: tagsModel
    resultsModel: options.resultsModel

  return {
    tagsModel: tagsModel
    view: view
    controller: controller
  }
