require 'rubygems'
require 'hpricot'
require "sqlite3"


def loadRecipesByName name
  
  db = SQLite3::Database.new($db+"draank.db")
  rows = db.execute("select * from recipes where name = ?", [name] )
  p rows
end

