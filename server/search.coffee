_ = require 'underscore'
xlsx = require 'node-xlsx'

_index = {}

class Ingredient
  constructor: (@text, @tag) ->

class Drink
  constructor: (row) ->
    @name = row[0].value.trim()
    # row[1] is self-notes, not for the user
    @instructions = row[2].value.trim()
    @notes = row[3]?.value.trim() ? ''
    @tags = []
    @ingredients = []
    for ingredient in _.tail row, 4
      parts = ingredient.value.split '|'
      if parts.length == 1
        @ingredients.push new Ingredient(parts[0].trim())
      else if parts.length == 2
        @tags.push parts[0].trim()
        @ingredients.push new Ingredient(parts[1].trim(), parts[0].trim())
      else
        console.warn "Malformed ingredient in #{@name}: '@{ingredient}'"

# Do we want to have unique identifiers for all drinks, or just use their names?
_tag_to_drink = {}
_all_drinks = []

exports.index = ->
  spreadsheet = xlsx.parse __dirname + '/../data/cocktails.xlsx'
  for row in spreadsheet.worksheets[0].data
    d = new Drink(row)
    for t in d.tags then (_tag_to_drink[t] ?= []).push d
    _all_drinks.push d
  console.log 'initialized search index'

# Takes two arrays, returns whether the first is a subset of the second.
# Assumes unordered. O(nm) for array lengths n, m.
_subset = (small, large) ->
  for s in small
    if not (s in large)
      return false
  return true

_tags = (query) ->
  return [] unless query.tags
  tags = _.map query.tags.split(','), (t) -> t.trim()
  results = []
  # This is nice and slow. How to index for subset checks?
  for d in _all_drinks
    if _subset d.tags, tags
      results.push d
  return _.uniq results

exports.search = (query) ->
  return _tags(query)

exports.tags = (substr) ->
  if substr?
    return _.filter _.keys(_tag_to_drink), (t) -> t.slice(0, substr.length) == substr
  return _.keys _tag_to_drink