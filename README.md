drinks
======

Requires `bower` and `npm`.

To run:
```
bower install
npm install -g http-server
http-server
```

Then go to [http://localhost:8080/](http://localhost:8080/).

Features
--------

- search by recipes you can make based on ingredients you have
- returns recipes you can almost make (and calls out which ingredients are missing)
- understands simple relationships between ingredients: if you have "lime", you must also have "lime juice"
- customizable recipe collection by editing recipes.json

Future
------

- support for different types of search, including drinks for a given ingredient or an all-drinks browse mode
- support for synonyms ("Baileys" comes up with "Irish cream")

Adding Recipes
--------------

Adding recipes is simple: add the appropriate things to `recipes.json` and possibly `derivatives.json`. Recipes have the following format:

- `name`: the human-readable name of the drink
- `ingredients`: an array of objects as described in the Ingredients section
- `instructions`: a human-readable string explaining how to mix the drink
- `notes`: any human-readable notes you'd like to add about the drink (optional)

When adding new ingredients, check `derivatives.json` to make sure any derivatives of the new ingredient are included as such. A "derivative" is any ingredient that can be assumed given the first, e.g., "lime juice" is a derivative of "lime" and "rum" is a derivative of "white rum". This makes it easier for the user when they search specific ingredients to receive results that are less specific. Use canonical names (as described in Ingredients, below) when declaring derivatives.

Ingredients
-----------

Ingredient search works because all ingredients are tagged with a canonical version of the ingredient in the data. This means that, for instance, '1.5oz Baileys' might be tagged as 'irish cream' so that you can search 'Irish Cream' and still get this recipe. Not all ingredients are searchable: garnishes or common ingredients like water may be left untagged. An ingredient is a simple object with the following fields:

  - `tag`: the canonical identifer for this ingredient (optional, left out if the ingredient isn't searchable)
  - `display`: a human-readable string explaining how to use this ingredient in this drink

Additionally, the `display` field understands some simple formatting to embellish the UI; the use of the following patterns in the string is strongly recommended:

  - `{q<amount>}`: where `<amount>` may be any string describing an amount (e.g. `1/2` or `1.5` or `1-3`)
  - `{u<unit>}`: where `<unit>` may be any string describing a unit (e.g. `part` or `oz` or `tsp`)

For now, the canonical name is exposed to the user as the searchable name, but this may change in the future.
