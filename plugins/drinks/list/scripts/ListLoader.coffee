do ->
  class drinks.list.ListLoader
    constructor: (options) ->
      _.extend @, options

    load: =>
      @list.reset [
        {},
        {},
        {}
      ]