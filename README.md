# aggressive-epsilon

Lightweight Rails JSON API for dealing with item reservations.

## Endpoints

+ `/item_types`

  This returns a collection of types of items which can be reserved. Each item type object has a name, as well as a list of item objects. Each item object has a name.

  Example response:

  ```json
    [{"name": "Apples",
      "items": [{"name": "Macintosh"},
                {"name": "Granny Smith"}]}]
  ```
