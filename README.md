# aggressive-epsilon

# Archived

We decided not to move forward with this (unfinished, not-yet-deployed) app since we abandoned microservices and also canceled the (planned, not-yet-started) customer-facing Field Trip app (which might've used some portions/concepts from this app). We reviewed the Golf Cart rental process and recommended tools like Trello to Parking staff (they opted to simply stick with email and a calendar). 

Lightweight Rails JSON API for dealing with item reservations.

[![Build Status](https://travis-ci.org/umts/aggressive-epsilon.svg?branch=master)](https://travis-ci.org/umts/aggressive-epsilon)
[![Test Coverage](https://codeclimate.com/github/umts/aggressive-epsilon/badges/coverage.svg)](https://codeclimate.com/github/umts/aggressive-epsilon/coverage)
[![Code Climate](https://codeclimate.com/github/umts/aggressive-epsilon/badges/gpa.svg)](https://codeclimate.com/github/umts/aggressive-epsilon)
[![Issue Count](https://codeclimate.com/github/umts/aggressive-epsilon/badges/issue_count.svg)](https://codeclimate.com/github/umts/aggressive-epsilon)

**This API is currently at version 1. All endpoints listed here are in the format `base_uri/v1/endpoint_uri`.**

## Customer service endpoints

These endpoints are structured so that customer service interfaces need not be concerned with IDs of objects other than reservations.

In general, reservations can only be edited by the customer service interface which created them, or by management interfaces which
have write access to the type of item which is reserved.

+ `GET /item_types`

  This endpoint returns a collection of types of items which can be reserved.
  Only items to which your service has been granted read access will be listed.
  Each item type object has a name, as well as a list of item objects and their names.
  Each item type object also has an `allowed_keys` field, which lists the keys
  which the items' metadata may contain. See `update_item` for details.

  A **response** will look like:

  ```json
    [{"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479", "name": "Apples",
      "allowed_keys": ["flavor"],
      "items": [{"name": "Macintosh", "uuid": "c3337a1d-694c-40cb-a16e-b77c33e8239d"},
                {"name": "Granny Smith", "uuid": "02790780-5e26-466b-9a41-26bd9c4b66a3"}]}]
  ```

  ---

+ `POST /reservations`

   This endpoint allows you to request reservations.
   It expects the name of an item type, an ISO 8601 start time, and an ISO 8601 end time.

   For instance, your **request** might look like:

   ```json
   POST /reservations
     {"item_type": "Apples",
      "start_datetime": "2016-02-16T15:30:00-05:00",
      "end_datetime": "2016-02-17T09:45:00-05:00"}
   ```

   If a reservation with those parameters is available, the attributes of the newly created reservation are returned.
   This universally unique identifier will be necessary for referencing the reservation later.

   A **success response** will look like:

   ```json
   {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479",
    "start_datetime": "2016-02-16T15:30:00-05:00",
    "end_datetime": "2016-02-17T09:45:00-05:00",
    "item_type": "Apples",
    "item": "Granny Smith"}
   ```

   If a reservation is not available, a blank response body is returned with a status of 422 (unprocessable entity).

   ---

+ `PUT /reservations/:uuid`

   This endpoint allows you to update the start or end times of a reservation.
   If you need a reservation for a different item type, the preferred method is to delete the current reservation
   and to create a new reservation for that item type.

   The start or end times should be in a `reservation` parameter, and should be in ISO 8601 format.

   For instance, your **request** might look like:

   ```json
   PUT /reservations/100
   {"reservation": {"start_datetime": "2016-02-16T18:00:00-05:00"}}
   ```

   If the change has been successfully applied, the new attributes will be returned.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Start time must be before end time"]}
   ```
   ---

+ `GET /reservations/:uuid`
 
  This endpoint allows you to doublecheck the attributes of any reservation which you have created.

  A **response** will look like:
  ```json
  {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479",
   "start_datetime": "2016-02-16T15:30:00-05:00",
   "end_datetime": "2016-02-17T09:45:00-05:00",
   "item_type": "Apples",
   "item": "Granny Smith"}
  ```

  ---

+ `DELETE /reservations/:uuid`

  This endpoint allows you to delete any reservation which you have created.
  If the reservation has been successfully deleted, a blank response body is returned with a status of 200.

  ---

+ `POST /reservations/:uuid/update_item`

   This endpoint allows you to update any of the metadata belonging to the item reserved in a particular reservation.
   At present, this is a destructive update - the existing metadata will be replaced with the given metadata.
   You can only specify metadata attributes which are in the `allowed_keys` of the item's type.

   The metadata should be in a `data` parameter.

   For instance, your **request** might look like:

   ```json
   POST /reservations/11ae0da2-b605-4d9b-8efb-443e59124479/update_item
   {"data": {"color": "orange"}}
   ```

   If the change has been successfully applied, a blank response body is returned with a status of 200.
   If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Disallowed key: color"]}
   ```

   ---

+ `GET /reservations`
   
   This endpoint returns all of the reservations for a particular item type in a given time range.
   You must have read access to the given item type.
   The `start_datetime` and `end_datetime` arguments must be in ISO 8601 format.
   Each reservation will list the start and end times in ISO 8601 format.

   For instance, your **request** might look like:
   
   ```json
   GET /reservations
   {"start_datetime": "2016-02-10T12:00:00-05:00",
    "end_datetime": "2016-02-17T12:00:00-05:00",
    "item_type": "Apples"}
   ```

   A **response** will look like:

   ```json
   [{"start_datetime": "2016-02-11T15:45:00-05:00", "end_datetime": "2016-02-11T21:00:00-05:00"},
    {"start_datetime": "2016-02-17T10:30:00-05:00", "end_datetime": "2016-02-19T21:00:00-05:00"}]
   ```
   
   ---

## Administration / management endpoints

+ `GET /item_types/:uuid`
  
  This endpoint lists the properties of an item type and of its items.
  You must have read access to the item type.
  Unlike `/item_types/`, this endpoint lists the UUID of each item.

  A **response** will look like:
  ```json
    {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479", "name": "Apples",
     "allowed_keys": ["flavor"],
     "items": [{"uuid": "facbabab-9cf9-4825-9a61-b2f11772d1c5", "name": "Macintosh"},
               {"uuid": "19eba890-b2ad-4014-86be-a79e0afb053a", "name": "Granny Smith"}]}
  ```
  
  ---
  
+ `PUT /item_types/:uuid`

  This endpoint allows you to change the name or allowed metadata keys of an item type to which you have write access.
  Item type changes should be in an `item_type` parameter.
  
  Your **request** might look like:
  ```json
  PUT /item_types/11ae0da2-b605-4d9b-8efb-443e59124479
  {"item_type": {"name": "Red/Green Fruit"}}
  ```
  
  If the change has been successfully applied, the new attributes will be returned.
  If there was an error in applying the change, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

   A **failure response** will look like:

   ```json
   {"errors": ["Name can't be blank"]}
   ```
   
   ---
   
+ `DELETE /item_types/:uuid`

  This endpoint allows you to delete an item type and its items, if you have write access to it.
  If the item type has been successfully deleted, a blank response body is returned with a status of 200.
  
  ---
  
+ `POST /item_types`

  This endpoint allows you to create an item type given a particular name.
  In order to create a new item type, you must have write access to at least one other item type.
  You may optionally specify what metadata keys you want other endpoints to be able to configure about items of this type, which should be an array.
  
  For example, your **request** might look like:
  
  ```json
  {"name": "Leather couches", "allowed_keys": ["texture", "length"]}
  ```
  
  If successful, the newly created item type will be returned to you, including its UUID.
  
  A **success response** will look like:
  
  ```json
  {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479", "name": "Leather couches", "allowed_keys": ["texture", "length"],
   "items": []}
  ```
  
  If there was an error, a list of errors will be returned with a status of 422 (unprocessable entity).
  
  A **failure response** will look like:
  
  ```json
  {"errors": ["Name can't be blank"]}
  ```
  
  ---

+ `POST /items`

  This endpoint allows you to create a new item of a given type. You must specify the type, and should specify the name.
  You can also set its metadata, providing that your metadata keys are in its type's allowed keys.
  You must have write access to the item's type.
  The attributes of the newly created item, including its UUID, will be returned to you if everything went well.
  If there is an error in creating your item, the endpoint will return a list of errors with a status of 422 (unprocessable entity).

  For example, your **request** might look like this:

  ```json
  POST /items
  {"name": "Awesome new couch", "item_type": {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"} , "reservable": true}
  ```

  A **success response** will look like:

  ```json
  {"uuid": 11ae0da2-b605-4d9b-8efb-443e59124478, "name": "Awesome new couch", "item_type": {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"}, "data": {}}
  ```

  A **failure response** will look like:

  ```json
  {"errors": ["Name can't be blank"]}
  ```

  ---

+ `GET /items`

  This endpoint allows you to view all of the items in a type, provided you have read access to that item type.

  For example, your **request** might look like:

  ```json
  GET /items
  {"item_type" => "uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"}}
  ```

  A **response** will look like:

  ```json
  {[{"uuid": "11ae0da2-b605-4d9b-8efb-443e59124478", "name": "Awesome new couch", "item_type" {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"}, "data": {}},
    {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124478", "name": "Cool leather futon", "item_type" {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"}, "data": {"texture": "leather"}}]}
  ```

  ---

+ `GET /items/:uuid`

  This endpoint allows you to view the attributes of an item, provided you have read access to its type.

  A **response** will look like:

  ```json
  {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124478", "name": "Awesome new couch", "item_type" {"uuid": "11ae0da2-b605-4d9b-8efb-443e59124479"}, "data": {}}
  ```
  
  ---

+ `PUT /items/:uuid`
  
  This endpoint allows you to update the attributes of an item. You must have write access to its type.
  To move an item from one type to another, you must have write access to both types.
  Item changes should be in an `item` parameter.
  If successful, the new attributes will be returned.
  IF there is an error applying your changes, a list of errors will be returned with a status of 422 (unprocessable entity).

  For example, your **request** might look like:

  ```json
  PUT /items/11ae0da2-b605-4d9b-8efb-443e59124479
  {"name": "Cool pleather futon", data: {"awesomeness": "factor 10"}}
  ```

  A **failure response** will look like:

  ```json
  {"errors": ["Disallowed key: awesomeness"]}
  ```

+ `DELETE /items/:uuid`

  This endpoint allows you to delete an item. You must have write access to its type.
  A blank response body with a status of 200 will be returned.
