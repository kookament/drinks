define [ 'marionette'
         'cs!./search-list'],
(Marionette, SearchList) ->
  return ->
    app = new Marionette.Application

    app.addRegions
      search: '#search-bar'
      results: '#search-results'
      instructions: '#instructions'

    listCollection = new SearchList.ResultCollection
    listView = new SearchList.ResultListView
      collection: listCollection

    app.start()

    app.results.show(listView)

    listCollection.add
      name: 'drink1'

    return app
