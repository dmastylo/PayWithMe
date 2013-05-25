PayWithMe
=========

Setting Up The Application
--------------------------

We're using `local.paywith.me` instead of `localhost` so that Facebook works. To set this up, just add `local.paywith.me` to `/etc/hosts` as you normally would to point a domain somewhere, most likely edit `/etc/hosts`. Nothing else is required to set up the local domain.

````
git clone git@github.com:austingulati/PayWithMe.git
cd PayWithMe
bundle install
rake db:setup
````

To run the server:

````
rails s
````

Reload your database using the following if you have some data accumulated and you want to clear it out:

````
rake db:reset
````

You need to make sure that `db:seed` runs at some point to populate the `payment_methods` table. The above mentioned tasks include `db:seed`.

Before running tests:

````
rake db:test:prepare
````
