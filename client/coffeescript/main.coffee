class DrinksList extends list.ListView
  className: 'list-view drink-list'

  events:
    'click .drink-title': 'clickDrink'

  generateItemElement: (item) ->
    $i = super
    $i.html $('<div class="drink-title">').text(item.get 'text')
    return $i

  clickDrink: (ev) ->
    console.log $(ev.target).html()

$(document).ready ->
  $('body').html Handlebars.templates['main']()

  resultsBundle = list.bundle
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

  tagRequest = $.ajax '/api/tags'
  tagRequest.done (data) ->
    searchBarBundle.tagsModel.set 'universe', data
