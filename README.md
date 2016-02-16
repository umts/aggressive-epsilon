# aggressive-epsilon

Lightweight Rails JSON API for dealing with item reservations.

## Endpoints

+ `GET /item_types`

  This endpoint returns a collection of types of items which can be reserved. Each item type object has a name, as well as a list of item objects. Each item object has a name.

  Example response:

  ```json
  GET /item_types
    [{"name": "Apples",
      "items": [{"name": "Macintosh"},
                {"name": "Granny Smith"}]}]
  ```
  ---

+ `POST /reservations`

   This endpoint accepts the name of an item type, an ISO 8601 start time, and an ISO 8601 end time.

   Example request:

   ```json
   POST /reservations
    {"item_type": "Apples",
     "start_time": "2016-02-16T15:30:00-05:00",
     "end_time": "2016-02-17T09:45:00-05:00"}
   ```

   If a reservation with those parameters is available, an object containing the ID of the newly created reservation is returned.
   This ID will be necessary for referencing the reservation later.

   Example success response:

   ```json
   {"id": 100}
   ```

   If a reservation is not available, a blank response body is returned with a status of 422 (unprocessable entity).
   ---

+ `PUT /reservations/:id`

   This endpoint allows you to update the start or end times of a reservation.
   If you need a reservation for a different item type, the preferred method is to delete the current reservation
   and to create a new reservation for that item type.

   The start or end times should be in a `reservation` parameter, and should be in ISO 8601 format.

   Example request:

   ```json
   PUT /reservations/100
   {"reservation": {"start_time": "2016-02-16T18:00:00-05:00"}}
   ```

   If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   Example failure response:

   ```json
   {"errors": ["Start time must be before end time"]}
   ```
   ---
