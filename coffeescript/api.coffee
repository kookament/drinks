api = window.api ?= {}

API_URL = '/api'

_default_handler = ->
  console.log arguments

api.search = (query, success, fail) ->
  req = $.ajax API_URL + '/search',
    type: 'GET'
    data: query
  req.done success ? _default_handler
  req.fail fail ? _default_handler
  return undefined
