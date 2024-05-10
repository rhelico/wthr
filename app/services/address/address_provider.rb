
module Address
  # A service class that provides an interface to interact with geocoding services.
  # TBH it would be simpler to leave the geocoder calls from the controller, but 
  # am going "enterprise" on purpose, assuming other uses outside the website
  #
  # The main method provided by this class, `search`, takes a query (which could be an address,
  # a set of coordinates, famous place name, or any other identifiable location data supported by 
  # Geocoder) and returns the geocoding results.
  #
  # Usage:
  #   address_provider = Address::AddressProvider.new
  #   results = address_provider.search("1600 Amphitheatre Parkway, Mountain View, CA")
  class AddressProvider
    # Performs a geocoding search using the Geocoder gem based on the provided query. This method
    # encapsulates the call to the Geocoder, making it the central point for modifications if
    # changes in the geocoding service or its configuration are required.
    #
    # @param query [String] the address or location query to be geocoded
    # @return [Array] an array of Geocoder::Result objects, each containing data about a location
    def search(query)
      Geocoder.search(query)
    end
  end
end
