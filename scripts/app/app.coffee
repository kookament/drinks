define [ 'marionette'
         'cs!./search'
         'cs!./search-list' ],
(Marionette, Search, SearchList) ->
  return ->
    app = new Marionette.Application

    app.addRegions
      search: '#search-sidebar'
      results: '#search-results'
      instructions: '#instructions'

    # todo: hook this up to a filtered collection
    searchSidebar = new Search.Sidebar

    listCollection = new SearchList.ResultCollection
    listView = new SearchList.ResultListView
      collection: listCollection

    app.start()

    app.search.show(searchSidebar)
    app.results.show(listView)

    listCollection.add
      name: 'drink1'

    return app
