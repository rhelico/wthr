module Address
  # This address service is bound to and abstracts away AddressProvider.
  # This is an incomplete abstraction.  AddressProvider could be a base class (like we did
  # with BaseFetcher.  It's better than a monolotihic class, and would allow us to easily swap
  # in different providers, or different output formats.
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
      results.map do |result|
        { formatted_address: result.address, latitude: result.coordinates[0], longitude: result.coordinates[1] }
      end
    end
  end
end