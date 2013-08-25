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
- support for saving your current ingredient selection
