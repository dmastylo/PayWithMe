# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

PaymentMethod.destroy_all
[
  {
    id: 1,
    name: "Cash",
    static_fee_cents: 0,
    percent_fee: 0,
    minimum_fee_cents: 0,
    fee_threshold_cents: 0
  },
  {
    id: 2,
    name: "PayPal",
    static_fee_cents: 30,
    percent_fee: 2.9,
    minimum_fee_cents: 0,
    fee_threshold_cents: 0
  },
  {
    id: 3,
    name: "Dwolla",
    static_fee_cents: 25,
    percent_fee: 0,
    minimum_fee_cents: 0,
    fee_threshold_cents: 1000
  },
  {
    id: 4,
    name: "WePay",
    static_fee_cents: 30,
    percent_fee: 2.9,
    minimum_fee_cents: 0,
    fee_threshold_cents: 0
  },
].each do |attributes|
  payment_method = PaymentMethod.new(attributes)
  payment_method.id = attributes[:id]
  payment_method.save
end

# [
#   [1, "Cash"],
#   [2, "PayPal"],
#   [3, "Dwolla"],
#   [4, "WePay"]
# ].each do |set|
#   payment_method = PaymentMethod.find_by_name(set[1])
#   payment_method.id = set[0]
#   payment_method.save!
# end