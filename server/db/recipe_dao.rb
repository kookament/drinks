require 'rubygems'
require 'hpricot'
require "sqlite3"

def loadRecipesByName name
  db = SQLite3::Database.new "draank.db"
  name = name.chomp
  rows = db.execute("select * from recipes where name = ?", [name] )
  p rows
end

loadRecipesByName "Electric Lemonade #3"
