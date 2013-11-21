define [
  'underscore'
  'cs!../app/recipe-search'
  'json!../data/sources.json'
], (
  _
  RecipeSearch
  sources
) ->
  # how many ingredients you can be missing and still have something come up
  _FUDGE_FACTOR = 2
  _GLASS_REGEX = /\{g([^\{]*)\}/

  recomputeMixableRecipes = (available) ->
    newRecipes = RecipeSearch.withAny(available.pluck('tag'), _FUDGE_FACTOR)
    newRecipes = _.chain(newRecipes).sortBy('name').sortBy('missing').value()

    for r in newRecipes
      if sources[r.source]
        r.source =
          name: sources[r.source].name
          url: r.url ? sources[r.source].url
      # ignore the {g} directive for now
      r.instructions = r.instructions.replace _GLASS_REGEX, '$1'

    lastMissing = -1
    i = 0
    while i < newRecipes.length # we use a while because we'll be adding stuff
      missing = newRecipes[i].missing
      if missing > lastMissing
        text = switch missing
          when 0 then 'mixable drinks'
          when 1 then '...with 1 more ingredient'
          else "...with #{missing} more ingredients"
        newRecipes.splice i, 0, { header : text }
        lastMissing = missing
        i++
      i++

    return newRecipes

  return {
    recomputeMixableRecipes
  }