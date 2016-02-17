# aggressive-epsilon

Lightweight Rails JSON API for dealing with item reservations.

## Endpoints

+ `GET /item_types`

  This endpoint returns a collection of types of items which can be reserved.
  Each item type object has a name, as well as a list of item objects and their names.
  Each item type object also has an `allowed_keys` field, which lists the keys
  which the items' metadata may contain. See `update_item` for details.

  Example response:

  ```json
  GET /item_types
    [{"name": "Apples",
      "allowed_keys": ["flavor"],
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

+ `GET /reservations/:id`
 
  This endpoint allows you to doublecheck the start and end times of any reservation which you have created.

  Example response:
  ```json
  GET /reservations/100
  {"start_time": "2016-02-17T12:00:00-05:00", "end_time": "2016-12-17T17:00:00-05:00"}
  ```

  If the requested reservation could not be found, a blank response body is returned with a 404 status.

  ---

+ `DELETE /reservations/:id`

  This endpoint allowed you to delete any reservation which you have created.
  If the reservation has been successfully deleted, a blank response body is returned with a status of 200.
  If the reservation could not be found, a 404 will be returned.

  ---

+ `POST /reservations/:id/update_item`

   This endpoint allows you to update any of the metadata belonging to the item reserved in a particular reservation.
   At present, this is a destructive update - the existing metadata will be replaced with the given metadata.
   You can only specify metadata attributes which are in the `allowed_keys` of the item's type.

   The metadata should be in a `data` parameter.

   Example request:

   ```json
   POST /reservations/100/update_item
   {"data": {"color": "orange"}}
   ```

   If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   Example failure response:

   ```json
   {"errors": ["Disallowed key: color"]}
   ```

   ---

+ `GET /reservations`
   
   This endpoint returns all of the reservations for a particular item type in a given time range.
   The `start_time` and `end_time` arguments must be in ISO 8601 format.
   Each reservation will list the start and end times in ISO 8601 format.
   If the requsted item type does not exist, the endpoint will return a blank response body and a 404.

   Example request:
   
   ```json
   GET /reservations
   {"start_time": "2016-02-10T12:00:00-05:00",
    "end_time": "2016-02-17T12:00:00-05:00",
    "item_type": "Apples"}
   ```

   Example response:

   ```json
   [{"start_time": "2016-02-11T15:45:00-05:00", "end_time": "2016-02-11T21:00:00-05:00"},
    {"start_time": "2016-02-17T10:30:00-05:00", "end_time": "2016-02-19T21:00:00-05:00"}]
   ```
