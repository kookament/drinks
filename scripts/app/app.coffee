define [ 'marionette'
         'cs!./search-list'],
(Marionette) ->
  return ->
    app = new Marionette.Application

    app.addRegions
      search: '#search-bar'
      results: '#search-results'
      instructions: '#instructions'

    app.start()

    return app
