define [ 'underscore'
         'yml!data/recipes.yml' ],
(_
 recipes) ->
  ingredients = _.chain(recipes)
    .pluck('ingredients')
    .flatten(true)
    .pluck('tag')
    .filter(_.identity)
    .map((i) -> i.toLowerCase())
    .sort()
    .uniq(true)
    .value()

  recipesForIngredients = {}
  for r in recipes
    _.chain(r.ingredients)
      .pluck('tag')
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

  withAny = (ingredients, flex = 0) ->
    return _.chain(ingredients)
      .map((i) -> recipesForIngredients[i])
      .flatten(true)
      .sortBy('name')
      .uniq(true, (r) -> r.name)
      .map((r) -> _.extend { missing: _countSubset(r.searchableIngredients, ingredients) }, r )
      .filter((r) -> r.missing <= flex)
      .value()

  withAll = (ingredients) ->
    return _.chain(ingredients)
      .map((i) -> recipesForIngredients[i])
      .flatten(true)
      .groupBy('name')
      .values()
      .filter((a) -> a.length == ingredients.length)
      .pluck('0')
      .value()

  return {
    recipes: recipes
    ingredients: ingredients
    withAny: withAny
    withAll: withAll
  }
