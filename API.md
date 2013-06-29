# PayWithMe Split Billing API Documentation

## Getting Started

(some initial information about setting up our API client, entering their keys, etc)

## Collections

Collections are the core of the PayWithMe process. The normal flow for a collection is as follows:

 1. A user is chooses to pay for their order using split billing from PayWithMe.
 2. Your system notifies PayWithMe of the details of the collection (collections#new).
 3. PayWithMe returns some basic information about the collection, including a URL for your customer to continue with their purchase.
 4. The customer visits the PayWithMe website. PayWithMe lets them configure their split bill.
 5. The customer's friends pay for their share of the purchase
 6. When everyone has paid, PayWithMe notifies your application that the split bill is paid and initiates a deposit into your bank account

### Creating collections

Creating a collection accepts the following attributes:

+==============================+=============+==================================================================+
| amount_per_person            | float       | The amount of money that each person has to pay. Either this     |
|                              |             | or `amount_total` is required.                                   |
| amount_total                 | float       | The total amount that is being collected. Either this or         |
|                              |             | `amount_per_person` is required. This amount is split evenly     |
|                              |             | among the whole group (note that the collection organizer pays   |
|                              |             | their own share.
(to be continued)

### Getting information on collections

### Updating collections

### Deleting collections

### Completed collections

When a collection is complete and all of the money has been collected, PayWithMe will notify your application that the collection is complete and initiate a deposit into your bank account. When the collection is created, the URL that PayWithMe will use to notify your application can be specified as complete_url. If this is not specified, the default complete_url set in the API Dashboard will be used. If no default complete_url is provided, your application will not be notified electronically but the status of the collection will still show up in the API Dashboard.

### Failed collections

The process for a failed collection is similar to that for a complete application. PayWithMe will notify your application that the collection has failed. When the collection is created, the URL that PayWithMe will use to notify your application can be specified as fail_url. If this is not specified, the default fail_url set in the API Dashboard will be used. If no default fail_url is provided, your application will not be notified electronically but the status of the collection will still show up in the API dashboard.