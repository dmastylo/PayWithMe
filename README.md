PayWithMe
=========

Setting Up The Application
--------------------------

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