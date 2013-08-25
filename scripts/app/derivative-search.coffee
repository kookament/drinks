define [ 'underscore'
         'json!../data/derivatives.json' ],
(_, derivatives) ->
  # derivatives are the mapping of have -> can make
  # this computes the inverse: claim can make -> must have one of
  # it's used for computing what things are no longer possible when source ingredients are removed
  _invertDerivatives = (obj) ->
    inverse = {}
    for k, v of obj
      if not _.isArray v
        throw new Error 'Malformed derivative directive for', k, ',', v
      for i in v
        (inverse[i] ?= []).push k
    return inverse

  inverseDerivatives = _invertDerivatives(derivatives)

  computeAdditions = (added, available) -> []

  computeRemovals = (removed, available) -> []

  return {
    computeAdditions: computeAdditions
    computeRemovals: computeRemovals
  }
