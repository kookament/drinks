require 'rubygems'
require "sqlite3"

def createCategoriesTable
  db = SQLite3::Database.new "draank.db"
  begin
    rows = db.execute <<-SQL
      drop table categories
    SQL
  rescue Exception => e
  #some log
  end
   rows = db.execute <<-SQL
    create table categories (
      id integer primary key asc,
      name varchar(256) UNIQUE,
      category varchar(256)
    );
  SQL
end

def createIngredientsTable
  db = SQLite3::Database.new "draank.db"
  begin
    rows = db.execute <<-SQL
      drop table ingredients
    SQL
  rescue Exception => e
  #some log
  end
   rows = db.execute <<-SQL
    create table ingredients (
      id integer primary key asc,
      name varchar(256) UNIQUE,
      category varchar(256)
    );
  SQL
end

def createRecipesTable
  db = SQLite3::Database.new "draank.db"
  begin
    rows = db.execute <<-SQL
      drop table recipes
    SQL
  rescue Exception => e
  #some log
  end
  
  rows = db.execute <<-SQL
    create table recipes (
      id integer primary key asc,
      name varchar(256) UNIQUE,
      ingredients varchar(1024),
      instructions varchar(1024)
    );
  SQL
end
createRecipesTable
