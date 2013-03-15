do ->
  class drinks.main.Drinks extends Backbone.View
    el: $('body')

    initialize: =>
      @_initializeModels()
      @_initializeLoaders()

      for name, l of @loaders
        l.load()

    _initializeModels: =>
      @models =
        list: new Backbone.Collection

      @models.list.model = drinks.list.ListItem

    _initializeLoaders: =>
      @loaders =
        list: new drinks.list.ListLoader
          list: @models.list

    render: =>
      l = $('<div/>').addClass('drinks-list').appendTo @$el

      l.render()
