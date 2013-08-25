define [ 'underscore'
         'json!../data/recipes.json' ],
(_, recipes) ->
  first = (i) ->
    if _.indexOf(i, '|') != -1
      return i.split('|')[0].trim()
    else
      return ''

  formattedStringToObject = (i) ->
    s = i.split('|', 2)
    if s.length == 1
      return {
        name: ''
        instruction: s[0].trim()
      }
    else
      return {
        name: s[0].trim()
        instruction: s[1].trim()
      }

  ingredients = _.chain(recipes)
    .pluck('ingredients')
    .flatten(true)
    .map(first)
    .filter(_.identity)
    .map((i) -> i.toLowerCase())
    .sort()
    .uniq(true)
    .value()

  recipesForIngredients = {}
  for r in recipes
    _.chain(r.ingredients)
      .map(first)
      .filter(_.identity)
      .uniq()
      .tap((i) -> r.searchableIngredients = i)
      .each((i) -> (recipesForIngredients[i] ?= []).push r)
    r.ingredients = _(r.ingredients).map formattedStringToObject

  _countSubset = (small, large) ->
    missed = 0
    for s in small
      if s not in large
        missed++
    return missed

  find = (ingredients, flex = 0) ->
    return _.chain(ingredients)
      .map((i) -> recipesForIngredients[i])
      .flatten(true)
      .sortBy('name')
      .uniq(true, (r) -> r.name)
      .filter((r) -> _countSubset(r.searchableIngredients, ingredients) <= flex)
      .value()

  return {
    recipes: recipes
    ingredients: ingredients
    find: find
  }
