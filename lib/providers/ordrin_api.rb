module Providers
  class OrdrinApi < LocationProvider
    include Ordrin

    def initialize
      @api = Ordrin::APIs.new(Figaro.env.ordrin_secret, :test)
    end

    def find_near(address={street:nil, city:nil, zip:nil})
      restaurants = @api.restaurant.get_delivery_list('ASAP', address)
      convert_restaurants(restaurants)
    end

    def get_test_address
      {street:'548 4th St', city:'San Francisco', zip:'94107'}
    end

    def get_test_restaurants
      find_near(get_test_address)
    end
  private

    def convert_restaurants(restaurants)
      converted_restaurants = []
      restaurants.each do |restaurant|
        converted_restaurant = Products::Restaurant.new
        converted_restaurant.id = restaurant["id"]
        converted_restaurant.provider = :ordrin
        converted_restaurant.name = restaurant[":na"]
        converted_restaurant.delivery = {time:restaurant["services"]["deliver"]["time"], minimum:restaurant["services"]["deliver"]["mino"], can:restaurant["is_delivering"]}
        converted_restaurant.types = restaurant["cu"]
        converted_restaurant.address = restaurant["addr"]
        converted_restaurants << converted_restaurant
      end
      converted_restaurants
    end
  end
end