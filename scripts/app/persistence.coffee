define [ 'underscore'
         'backbone' ],
(_
  Backbone) ->
  _LOCAL_STORAGE_NAME = 'drinks-app-ingredients'

  class Ingredients
    constructor: ({@ingredients}) ->
      _.extend this, Backbone.Events

      @listenTo @ingredients, 'change:selected', @save

    save: ->
      localStorage[_LOCAL_STORAGE_NAME] = JSON.stringify _.chain(@ingredients.models)
        .filter((m) -> m.get 'selected')
        .map((m) -> m.get 'tag')
        .value()

    load: ->
      if localStorage[_LOCAL_STORAGE_NAME]
        for tag in JSON.parse localStorage[_LOCAL_STORAGE_NAME]
          @ingredients.findWhere(tag: tag).set 'selected', true

  return {
    Ingredients: Ingredients
  }