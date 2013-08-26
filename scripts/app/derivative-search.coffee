define [ 'underscore'
         'json!../data/derivatives.json' ],
(_
 derivatives) ->
  # derivatives are the mapping of have -> can make
  # this computes the inverse: claim can make -> must have one of
  # it's used for computing what things are no longer possible when source ingredients are removed
  _invertDerivatives = (obj) ->
    inverse = {}
    for k, v of obj
      if not _.isArray v
        throw new Error "Malformed derivative directive for '#{k}'."
      for i in v
        (inverse[i] ?= []).push k
    return inverse

  inverseDerivatives = _invertDerivatives(derivatives)

  computeAdditions = (added, available) ->
    d = derivatives[added]
    if d?.length
      return d
    else
      return []

  computeRemovals = (removed, available) ->
    d = derivatives[removed]
    if d?.length
      removed = []
      for ing in d
        makeable = false
        for inv in inverseDerivatives[ing]
          if inv in available
            makeable = true
            break
        if not makeable
          removed.push ing
      return removed
    else
      return []

  return {
    computeAdditions: computeAdditions
    computeRemovals: computeRemovals
  }
