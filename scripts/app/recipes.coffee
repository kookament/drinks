define [ 'underscore'
         'json!../data/recipes.json' ],
(_, recipes) ->
  first = (i) -> i.split('|')[0].trim()

  ingredients = _.chain(recipes)
    .pluck('ingredients')
    .flatten(true)
    .map(first)
    .sort()
    .uniq(true)
    .value()

  recipesForIngredients = {}
  for r in recipes
    _.chain(r.ingredients, first)
      .map(first)
      .uniq()
      .each((i) -> (recipesForIngredients[i] ?= []).push r)

  find = (ingredients, flex = 0) ->
    return recipes

  return {
    recipes: recipes
    ingredients: ingredients
    find: find
  }
