class AddressesController < ApplicationController
  include SemanticLogger::Loggable

  # Provides address autocomplete functionality.
  #
  # This method takes a user query and uses the Address::AddressService to return a list
  # of addresses that match the query. It then returns the results as a JSON response.
  #
  # @param [String] query The search string entered by the user to find addresses.
  #
  # @return [JSON] A JSON array of addresses, each containing:
  #   - formatted_address [String]: The full address as a string.
  #   - latitude [Float]: The latitude of the address.
  #   - longitude [Float]: The longitude of the address.
  #
  # Errors:
  # - If the query parameter is missing or empty, an empty array is returned.
  # - If the AddressService raises an error, an empty array is returned,
  #   and an error message is logged.
  def autocomplete
    query = params[:query]

    if query.present?
      begin
        address_service = Address::AddressService.new
        addresses = address_service.autocomplete(query)
      rescue StandardError => e
        logger.error "Address service error: #{e.message}"
        addresses = []
      end
    else
      logger.debug "No addresses yet"
      addresses = []
    end

    render json: addresses
  end
end