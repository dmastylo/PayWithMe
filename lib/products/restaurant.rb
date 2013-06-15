module Products
  class Restaurant < Product
    attr_accessor :id, :provider, :name, :phone, :delivery, :types, :address
  end
end