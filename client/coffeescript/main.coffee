class DrinksList extends list.ListView
  className: 'list-view drink-list'

  generateItemElement: (item) ->
    $item = super
    $item.html Handlebars.templates['drink-list-item'](item.attributes)
    return $item

  clickItem: (m, ev) ->
    super
    @inspectModel?.set 'drink', m

$(document).ready ->
  $('body').html Handlebars.templates['main']()

  resultsBundle = list.bundle
    itemClass: drink.Drink
    viewClass: DrinksList
  resultsBundle.view.render()

  searchBarBundle = search.bundle
    resultsModel: resultsBundle.model
  searchBarBundle.view.render()

  $('.search-header').append searchBarBundle.view.$el
  $('.results-panel').append resultsBundle.view.$el

  inspectBundle = inspect.bundle()
  inspectBundle.view.render()

  $('.inspect-panel').append inspectBundle.view.$el

  # Glue.
  resultsBundle.view.inspectModel = inspectBundle.model

  tagRequest = $.ajax '/api/tags'
  tagRequest.done (data) ->
    searchBarBundle.tagsModel.set 'universe', data
