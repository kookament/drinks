# # http://www.webtender.com/db/drink/
# # Walker Holahan 3/10/13

require 'rubygems'
require 'hpricot'
require 'open-uri'
require "sqlite3"

def pullDataFromWebTender # poor bastards
  db = SQLite3::Database.new "draank.db"
  j = 6216
  # Create a database
  
  j.times do |time|
    begin
      doc = open("http://www.webtender.com/cgi-bin/printdrink?" + (time+1).to_s) { |f| Hpricot(f) }
    rescue OpenURI::HTTPError => e
      p e
      next
    end
    
    name = doc.search("/html/body/h1").inner_html
    ingredients = doc.search("/html/body/ul").inner_html
    ingredients = ingredients.strip.gsub(/<(.*?)>/, '').split("\n").join(", ")
    instructions = doc.search("/html/body/p[3]").inner_html
    
    # print all the shit
    p name
    p ingredients
    p instructions
    print "\n"
    
    begin
      db.execute "insert into recipes values (?, ?, ?, ?)", [time, name, ingredients, instructions] 
    rescue SQLite3::ConstraintException => boom
      p name + " already exists in db."
    end
  end
end

def listRecipes 
  db = SQLite3::Database.new "draank.db"
  rows = db.execute("select * from recipes" )
  rows.each do |row|
    p row[2] 
  end
 
end

def buildIngredientsTable # stubbed for now
  db = SQLite3::Database.new "draank.db"
  rows = db.execute("select * from recipes")
  things = [] 
  
  rows.each do |row|
    p row[2]
    row[2].split(",").each do |item|
      things << item.strip.split(" ")[1]
    end    
    print "\n"
  end
  # p things.uniq
end

# "1 L Sprite, 2 cups Pink lemonade, 2 cups Vodka"

pullDataFromWebTender