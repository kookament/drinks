class DrinksList extends list.ListView
  className: 'list-view drink-list'

  events:
    'click .drink-title': '_clickDrink'

  generateItemElement: (item) ->
    $i = super
    $i.html $('<div class="drink-title">').text(item.get 'text')
    return $i

  _clickDrink: (ev) ->
    # Currently, the html == the name, which is the unique identifier. Clearly this system will not work in the general case.
    d = @model.get('items').where { name: $(ev.target).html() }
    switch d.length
      when 0 then console.error "Could not locate model for click on #{ev.target}."
      when 1 then @_selectDrink d[0], ev
      else console.error "Multiple models matched for click on #{ev.target}: #dm}."

  _selectDrink: (d, ev) ->
    @inspectModel?.set 'drink', d
    # TODO: Need a unique identifier for the drinks so I can tag the DOM element and find it later to select it.
    # @$('.list-item').removeClass('selected').find()

class Drink extends Backbone.Model
  defaults: ->
    name: ''
    tags: []
    ingredients: []
    description: ''

$(document).ready ->
  $('body').html Handlebars.templates['main']()

  resultsBundle = list.bundle
    itemClass: Drink
    viewClass: DrinksList
  resultsBundle.view.render()

  searchBarBundle = search.bundle
    resultsModel: resultsBundle.model
  searchBarBundle.view.render()

  $('.search-panel').append searchBarBundle.view.$el
  $('.search-panel').append resultsBundle.view.$el

  inspectBundle = inspect.bundle()
  inspectBundle.view.render()

  $('.inspect-panel').append inspectBundle.view.$el

  # Glue.
  resultsBundle.view.inspectModel = inspectBundle.model

  tagRequest = $.ajax '/api/tags'
  tagRequest.done (data) ->
    searchBarBundle.tagsModel.set 'universe', data
