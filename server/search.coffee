_ = require 'underscore'
fs = require 'fs'
xlsx = require 'node-xlsx'
DependencyGraph = require 'dep-graph'

_index = {}
_derivatives = {}

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
    d = new Drink row
    for t in d.tags then (_tag_to_drink[t] ?= []).push d
    _all_drinks.push d

  derivativeJson = JSON.parse fs.readFileSync(__dirname + '/../data/derivatives.json')
  graph = new DependencyGraph
  for k, v of derivativeJson
    graph.add k, v

  for d in _.keys derivativeJson
    _derivatives[d] = graph.getChain d

  console.log 'initialized search index'

# Takes two arrays, returns how many of small are not in large (i.e., how many ingredients
# are missing from the search set, large, to be able to make the drink, small).
# Assumes unordered. theta(nm) for array lengths n, m.
_subset_count = (small, large) ->
  missed = 0
  for s in small
    if not (s in large)
      missed++
  return missed

_tags = (query) ->
  return [] unless query.tags
  tags = _.map query.tags.split(','), (t) -> t.trim()
  for t in _.clone tags
    tags = tags.concat(_derivatives[t] ? [])
  tags = _.uniq tags
  results = {}
  # This is really slow.
  (results[_subset_count d.tags, tags] ?= []).push(d) for d in _all_drinks
  return results

exports.search = (query) ->
  return _.pick _tags(query), [0..2]

exports.tags = (substr) ->
  if substr?
    return _.filter _.keys(_tag_to_drink), (t) -> t.slice(0, substr.length) == substr
  return _.keys _tag_to_drink
