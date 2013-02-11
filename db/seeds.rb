# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

PaymentMethod.create(
  [
    {
      name: "Cash",
      static_fee_cents: 0,
      percent_fee: 0,
      minimum_fee_cents: 0,
      fee_threshold_cents: 0
    },
    {
      name: "PayPal",
      static_fee_cents: 30,
      percent_fee: 2.9,
      minimum_fee_cents: 0,
      fee_threshold_cents: 0
    },
    {
      name: "Dwolla",
      static_fee_cents: 25,
      percent_fee: 0,
      minimum_fee_cents: 0,
      fee_threshold_cents: 1000
    }
  ]
)