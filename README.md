PayWithMe
=========

Setting Up The Application
--------------------------

We're using `local.paywith.me` instead of `localhost` so that Facebook works. To set this up, just add `local.paywith.me` to `/etc/hosts` as you normally would to point a domain somewhere. Nothing else is required.

````
git clone git@github.com:austingulati/PayWithMe.git
cd PayWithMe
bundle install
rake db:setup
````

Reload your database using the following:

````
rake db:reset
````

You need to make sure that `db:seed` runs at some point to populate the `payment_methods` table. The above mentioned tasks include `db:seed`.

To run tests:

````
rake db:test:prepare
````

