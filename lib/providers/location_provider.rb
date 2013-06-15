module Providers
  # A location provider provides things related to  a location
  class LocationProvider < Provider
    def find_near(options={street:nil, city:nil, zip:nil}); end # Gets offers near
  end
end