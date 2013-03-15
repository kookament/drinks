require 'recipe_dao'
class Recipe 
   def new id, name, ingredients, instructions
     @id = id
     @name = name
     @ingredients = ingredients
     @instructions = instructions  
   end
   
   def id
     @id
   end
   
   def name
     @name
   end
   
   def ingredients
     @ingredients
   end
   
   def instructions
     @instructions
   end
   
   def self.find_by_name name
     found = []
       ObjectSpace.each_object(Recipe) { |o|
      found << o if o.name == name
    }
    if found == []
      found = loadRecipesByName name
    else
      found
    end
   end
end