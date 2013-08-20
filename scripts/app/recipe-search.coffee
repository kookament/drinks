define [ 'underscore'
         'json!../data/recipes.json' ],
(_, recipes) ->
  first = (i) ->
    if i.indexOf('|') != -1
      return i.split('|')[0].trim()
    else
      return ''

  ingredients = _.chain(recipes)
    .pluck('ingredients')
    .flatten(true)
    .map(first)
    .filter(_.identity)
    .sort()
    .uniq(true)
    .value()

  recipesForIngredients = {}
  for r in recipes
    _.chain(r.ingredients, first)
      .map(first)
      .filter(_.identity)
      .uniq()
      .tap((i) -> r.searchableIngredients = i)
      .each((i) -> (recipesForIngredients[i] ?= []).push r)

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
