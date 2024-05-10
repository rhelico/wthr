module Address
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