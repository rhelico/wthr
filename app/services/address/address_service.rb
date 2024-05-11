module Address
  # This address service is bound to and abstracts away AddressProvider.
  # This is an incomplete abstraction.  AddressProvider could be a base class (like we did
  # with BaseFetcher.  It's better than a monolotihic class, and would allow us to easily swap
  # in different providers, or different output formats.
  #
  # I forward the postal code as it's necessary for the assigned cacheing strategy.
  #
  # Example usage:
  #   address_service = Address::AddressService.new
  #   autocomplete_results = address_service.autocomplete("1600 Amphitheatre Parkway")
  #
  class AddressService
    def initialize(address_provider = AddressProvider.new)
      @provider = address_provider
    end

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