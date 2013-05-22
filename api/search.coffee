_ = require 'underscore'
xlsx = require 'node-xlsx'

_index = {}

class Drink
  constructor: (row) ->
    @name = row[0].value.trim()
    @tags = _.map(row[1].value.split(','), (t) -> t.trim())
    @ingredients = _.map(row[2].value.split('|'), (t) -> t.trim())
    @description = row[3].value.trim()

# Do we want to have unique identifiers for all drinks, or just use their names?
_tag_to_drink = {}
_all_drinks = []

exports.index = ->
  spreadsheet = xlsx.parse __dirname + '/../data/cocktails.xlsx'
  # This also grabs the header row -- we'll have to get rid of that.
  for row in spreadsheet.worksheets[0].data
    d = new Drink(row)
    for t in d.tags then (_tag_to_drink[t] ?= []).push d
    _all_drinks.push d
  console.log 'initialized search index'

_tags = (query) ->
  return [] unless query.tags
  tags = _.map query.tags.split(','), (t) -> t.trim()
  results = []
  for t in tags
    if _tag_to_drink[t]
      results = results.concat _tag_to_drink[t]
  return _.uniq results

_searches =
  tags: _tags

exports.search = (query) ->
  result = []
  for type, f of _searches
    result = result.concat f(query)
  return result

exports.tags = (substr) ->
  if substr?
    return _.filter _.keys(_tag_to_drink), (t) -> t.slice(0, substr.length) == substr
  return _.keys _tag_to_drink