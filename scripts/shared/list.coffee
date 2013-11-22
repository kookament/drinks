# This file exists mostly to standardize class naming and scroll behavior
# across the various lists.
define [
  'marionette'
  'less!../../styles/list'
], (
  Marionette
) ->
  class ListView extends Marionette.CollectionView
    className : -> 'list'
    itemView  : ListItemView
    emptyView : EmptyListView

  class ListItemView extends Marionette.ItemView
    className : -> 'list-item'
    template  : -> ''

  class EmptyListView extends Marionette.ItemView
    className : -> 'empty-list-item'
    template  : -> ''

  return {
    ListView
    ListItemView
    EmptyListView
  }
