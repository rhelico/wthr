module Address
  # This service class abstracts the interaction with the address provider, Google Maps Geocoding API.
  # The idea is to separate the provider - could be any api - from the service by abstracting the 
  # provider through dependency injection.
  #
  # Example usage:
  #   address_service = Address::AddressService.new(address_provider)
  #   autocomplete_results = address_service.autocomplete("1600 Amphitheatre Parkway")
  #
  class AddressService
    def initialize(address_provider = AddressProvider.new)
      @provider = address_provider
    end

    # Returns an array of formatted address results based on the input query.
    #
    # @param query [String] The search query for address autocompletion.
    # @return [Array<Hash>] A list of hashes each containing formatted address details.

    def autocomplete(query)
      results = @provider.search(query)
      Rails.logger.info "Address service results: #{results}"
      results.map do |result|{
        formatted_address: result.data["formatted_address"],
        latitude: result.data["geometry"]["location"]["lat"],
        longitude: result.data["geometry"]["location"]["lng"],
        postal_code: extract_postal_code(result.data["address_components"])
      }
      end
    end
    
    # Extracts the postal code from the address components array.
    # Each component is a hash with `long_name`, `short_name`, and `types`.
    # The method finds the component where `types` includes 'postal_code' and returns its `long_name`.
    #
    # @param address_components [Array<Hash>] the address components
    # @return [String] the postal code
    def extract_postal_code(address_components)
      postal_component = address_components.find { |component| component["types"].include?("postal_code") }
      postal_component ? postal_component["long_name"] : nil
    end
  end
end