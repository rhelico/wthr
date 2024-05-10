module Address
  class AddressProvider
    def search(query)
      Geocoder.search(query)
    end
  end
end
