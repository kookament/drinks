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

class MainView extends Backbone.View
  className: 'main-view'

  render: ->
    @$el.html Handlebars.templates.main()

$(document).ready ->
  view = new MainView
  view.render()

  $('body').html view.$el

  $body = $('body')
  $search = $('input[type="hidden"]')
  $submit = $('input[type="submit"]')

  results = new list.bundle
    viewClass: DrinksList
  results.view.render()

  $body.append results.view.$el

  $search.width 400

  tags = $.ajax '/api/tags'
  tags.done (data) ->
    $search.select2
      placeholder: 'enter some tags'
      tags: data
      createSearchChoice: -> # Prevent user from creating novel tags.
      openOnEnter: false
  tags.fail ->
    console.error 'There was and error loading the tags and now everything is broken.'

  $submit.click ->
    api.forTags $search.select2('val'), (data) ->
      results.model.get('items').reset _.map data, (d) -> _.defaults { text: d.name }, d
