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
  $('body').html Handlebars.templates.main()

  results = list.bundle
    viewClass: DrinksList
  results.view.render()

  bar = search.bundle
    resultsModel: results.model
  bar.view.render()

  $('.search-panel').append bar.view.$el
  $('.search-panel').append results.view.$el

  tagRequest = $.ajax '/api/tags'
  tagRequest.done (data) ->
    bar.tagsModel.set 'universe', data
