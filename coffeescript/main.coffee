$(document).ready ->
  $body = $('body')
  $search = $('<input type="hidden"/>').appendTo $body
  $submit = $('<input type="submit"/>').appendTo $body
  $results = $('<div/>').appendTo $body

  $search.width 400

  tags = $.ajax '/api/tags'
  tags.done (data) -> 
    $search.select2
      placeholder: 'enter some tags'
      tags: data
      createSearchChoice: -> # Prevent user from creating novel tags.
  tags.fail ->
    console.error 'There was and error loading the tags and now everything is broken.'

  $submit.click ->
    api.forTags $search.select2('val'), (data) -> $results.text _.pluck data, 'name'
