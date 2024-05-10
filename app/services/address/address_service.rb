module Address
  class AddressService
    def initialize
      @provider = AddressProvider.new
    end

    def autocomplete(query)
      results = @provider.search(query)
      results.map do |result|
        {
          formatted_address: result.address,
          latitude: result.coordinates[0],
          longitude: result.coordinates[1]
        }
      end
    end
  end
end
