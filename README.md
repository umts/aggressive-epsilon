# aggressive-epsilon

Lightweight Rails JSON API for dealing with item reservations.

## Endpoints

+ `GET /item_types`

  This endpoint returns a collection of types of items which can be reserved. Each item type object has a name, as well as a list of item objects. Each item object has a name.

  Example response:

  ```json
    [{"name": "Apples",
      "items": [{"name": "Macintosh"},
                {"name": "Granny Smith"}]}]
  ```

+ `POST /reservations`

   This endpoint accepts the name of an item type, an ISO 8601 start time, and an ISO 8601 end time.

   Example request:

   ```json
    {"item_type": "Apples",
     "start_datetime": "2016-02-16T15:30:00-05:00",
     "end_datetime": "2016-02-17T09:45:00-05:00"}
   ```

   If a reservation with those parameters is available, an object containing the ID of the newly created reservation is returned.
   This ID will be necessary for referencing the reservation later.

   Example success response:

   ```json
     {"id": 100}
   ```

   If a reservation is not available, a blank response body is returned with a status of 422 (unprocessable entity).
